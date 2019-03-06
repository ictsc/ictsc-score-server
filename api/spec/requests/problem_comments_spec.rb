require_relative '../spec_helper.rb'

describe 'Problem comment' do
  include ApiHelpers

  before(:each) {
    time = DateTime.parse("2017-07-07T21:00:00+09:00")
    allow(DateTime).to receive(:current).and_return(time)
    allow(Config).to receive(:competition_start_at).and_return(time - 3.year)
  }

  let(:member) { current_member || create(:member) }
  let(:team) { current_member&.team || create(:team) }
  let(:creator) do
    if current_member&.role == build(:role, :writer)
      current_member
    else
      build(:member, :writer)
    end
  end
  let(:problem) { create(:problem, creator: creator) }
  let(:problem_participant_cant_see) do
    before_problem = create(:problem)
    create(:problem, creator: creator, problem_must_solve_before: before_problem)
  end


  describe "GET /api/problems/:problem_id/comments" do
    let!(:comments) { create_list(:"problem_comment", 2, member: member, commentable: problem) }
    let!(:comments_by_other_member) { create_list(:"problem_comment", 2, member: create(:member), commentable: problem) }

    let(:response) { get "/api/problems/#{problem.id}/comments" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 200 }
    by_participant { is_expected.to eq 200 }
    by_writer      { is_expected.to eq 200 }
    by_admin       { is_expected.to eq 200 }

    context 'when contest stop' do
      before { allow(Config).to receive(:competition_stop).and_return(true) }
      subject { response.status }

      by_nologin     { is_expected.to eq 404 }
      by_participant { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 404 }
      by_writer      { is_expected.to eq 200 }
      by_admin       { is_expected.to eq 200 }
    end

    describe '#size' do
      subject { json_response.size }
      by_viewer      { is_expected.to eq 4 }
      by_participant { is_expected.to eq 4 }
      by_writer      { is_expected.to eq 4 }
      by_admin       { is_expected.to eq 4 }
    end
  end

  describe "GET /api/problems/:problem_id/comments to problem participant can't see" do
    let(:problem) { problem_participant_cant_see }
    let!(:comments) { create_list(:"problem_comment", 2, member: member, commentable: problem) }
    let!(:comments_by_other_member) { create_list(:"problem_comment", 2, member: create(:member), commentable: problem) }

    let(:response) { get "/api/problems/#{problem.id}/comments" }
    subject { response.status }

    by_participant { is_expected.to eq 404 }
  end

  describe "GET /api/problems/:problem_id/comments/:id" do
    let!(:comment) { create(:"problem_comment", member: member, commentable: problem) }

    let(:response) { get "/api/problems/#{problem.id}/comments/#{comment.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 200 }
    by_participant { is_expected.to eq 200 }
    by_writer      { is_expected.to eq 200 }
    by_admin       { is_expected.to eq 200 }

    describe "comment created by other member" do
      let!(:comment) { create(:"problem_comment", member: create(:member), commentable: problem) }
      by_participant { is_expected.to eq 200 }
    end

    describe '#keys' do
      let(:expected_keys) { %w(id text member_id created_at updated_at commentable_type commentable_id) }
      subject { json_response.keys }
      by_viewer      { is_expected.to match_array expected_keys }
      by_participant { is_expected.to match_array expected_keys }
      by_writer      { is_expected.to match_array expected_keys }
      by_admin       { is_expected.to match_array expected_keys }
    end
  end

  describe "GET /api/problems/:problem_id/comments/:id to problem participant can't see" do
    let(:problem) { problem_participant_cant_see }
    let!(:comment) { create(:"problem_comment", member: member, commentable: problem) }

    let(:response) { get "/api/problems/#{problem.id}/comments/#{comment.id}" }
    subject { response.status }

    by_participant { is_expected.to eq 404 }
  end

  describe "POST /api/problems/:problem_id/comments" do
    let!(:other_member) { create(:member) }
    let(:comment) { build(:problem_comment) }

    let(:params) do
      {
        text: comment.text,
        member_id: other_member.id
      }
    end

    describe 'create comment' do
      let(:expected_keys) { %w(id text member_id created_at updated_at commentable_type commentable_id) }
      let(:response) { post "/api/problems/#{problem.id}/comments", params }
      subject { response.status }

      by_nologin     { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 404 }
      by_participant { is_expected.to eq 404 }

      by_writer do
          is_expected.to eq 201
          expect(json_response.keys).to match_array expected_keys
          # member_idは偽造できない
          expect(json_response['member_id']).not_to eq other_member.id
      end

      by_admin do
        is_expected.to eq 201
        expect(json_response.keys).to match_array expected_keys
        expect(json_response['member_id']).to eq other_member.id
      end
    end

    describe 'create comment with other creator' do
      let!(:other_member) { create(:member) }
      let(:problem) { create(:problem, creator: other_member) }
      let(:comment) { build(:problem_comment) }
      let(:params) do
        {
          text: comment.text,
          member_id: other_member.id
        }
      end
      let(:expected_keys) { %w(id text member_id created_at updated_at commentable_type commentable_id) }
      let(:response) { post "/api/problems/#{problem.id}/comments", params }
      subject { response.status }

      by_writer do
        is_expected.to eq 201
        expect(json_response.keys).to match_array expected_keys
      end
    end

    describe 'create comment with missing text' do
      let(:params_without_text) { params.except(:text) }
      let(:response) { post "/api/problems/#{problem.id}/comments", params_without_text }
      subject { response.status }

      by_writer      { is_expected.to eq 400 }
      by_admin       { is_expected.to eq 400 }
    end
  end

  describe "PUT, PATCH /api/problems/:problem_id/comments" do
    let!(:comment) { create(:"problem_comment", member: member, commentable: problem) }
    let(:new_text) { comment.text + 'nya-' }

    describe "edit comment" do
      let(:params) do
        {
          text: new_text,
          member_id: comment.member_id
        }
      end

      shared_examples 'expected success statuses' do
        subject { response.status }

        by_nologin     { is_expected.to eq 404 }
        by_viewer      { is_expected.to eq 404 }
        by_participant { is_expected.to eq 404 }
        by_writer      { is_expected.to eq 200 }
        by_admin       { is_expected.to eq 200 }
      end

      context 'PUT without text' do
        let(:response) { put "/api/problems/#{problem.id}/comments/#{comment.id}", params.except(:text) }
        subject { response.status }

        by_nologin     { is_expected.to eq 404 }
        by_viewer      { is_expected.to eq 404 }
        by_participant { is_expected.to eq 404 }
        by_writer      { is_expected.to eq 400 }
        by_admin       { is_expected.to eq 400 }
      end

      context 'PATCH without text' do
        let(:response) { patch "/api/problems/#{problem.id}/comments/#{comment.id}", params.except(:text) }
        it_behaves_like 'expected success statuses'

        by_writer      { expect(json_response['text']).to eq comment.text }
        by_admin       { expect(json_response['text']).to eq comment.text }
      end

      context 'PUT' do
        let(:response) { put "/api/problems/#{problem.id}/comments/#{comment.id}", params }
        it_behaves_like 'expected success statuses'

        by_writer      { expect(json_response['text']).to eq new_text }
        by_admin       { expect(json_response['text']).to eq new_text }
      end
    end
  end

  describe "DELETE /api/problems/:problem_id/comments/:id" do
    let!(:comment) { create(:"problem_comment") }

    let(:response) { delete "/api/problems/#{problem.id}/comments/#{comment.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 404 }
    by_participant { is_expected.to eq 404 }
    by_writer      { is_expected.to eq 204 }
    by_admin       { is_expected.to eq 204 }
  end
end
