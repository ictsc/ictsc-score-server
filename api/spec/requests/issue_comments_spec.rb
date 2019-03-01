require_relative '../spec_helper.rb'

describe 'Issue comments' do
  include ApiHelpers

  before(:each) {
    time = DateTime.parse("2017-07-07T21:00:00+09:00")
    allow(DateTime).to receive(:current).and_return(time)
    allow(Config).to receive(:competition_start_at).and_return(time - 3.year)
  }

  let(:member) { current_member || create(:member) }
  let(:team) { current_member&.team || create(:team) }
  let(:issue) { create(:issue, team: team) }

  describe "GET /api/issues/:issue_id/comments" do
    let!(:comments) { create_list(:"issue_comment", 2, member: member, commentable: issue) }
    let!(:comments_by_other_member) { create_list(:"issue_comment", 2, member: create(:member), commentable: issue) }

    let(:response) { get "/api/issues/#{issue.id}/comments" }
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

  describe "GET /api/issues/:issue_id/comments to other team's issue" do
    let(:issue_by_other_team) { create(:issue, team: create(:team)) }
    let(:issue) { issue_by_other_team }
    let!(:comments) { create_list(:"issue_comment", 2, member: member, commentable: issue) }
    let!(:comments_by_other_member) { create_list(:"issue_comment", 2, member: create(:member), commentable: issue) }

    let(:response) { get "/api/issues/#{issue.id}/comments" }
    subject { response.status }

    by_participant { is_expected.to eq 404 }
  end

  describe "GET /api/issues/:issue_id/comments/:id" do
    let!(:comment) { create(:"issue_comment", member: member, commentable: issue) }

    let(:response) { get "/api/issues/#{issue.id}/comments/#{comment.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 200 }
    by_participant { is_expected.to eq 200 }
    by_writer      { is_expected.to eq 200 }
    by_admin       { is_expected.to eq 200 }

    describe "comment created by other member" do
      let!(:comment) { create(:"issue_comment", member: create(:member), commentable: issue) }
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

  describe "GET /api/issues/:issue_id/comments/:id to other team's issue" do
    let(:issue_by_other_team) { create(:issue, team: create(:team)) }
    let(:issue) { issue_by_other_team }
    let!(:comment) { create(:"issue_comment", member: member, commentable: issue) }

    let(:response) { get "/api/issues/#{issue.id}/comments/#{comment.id}" }
    subject { response.status }

    by_participant { is_expected.to eq 404 }

    describe "comment created by other team's member" do
      let!(:comment) { create(:"issue_comment", member: create(:member), commentable: issue) }
      by_participant { is_expected.to eq 404 }
    end
  end

  describe "POST /api/issues/:issue_id/comments" do
    let!(:other_member) { create(:member) }
    let(:comment) { build(:"issue_comment") }

    let(:params) do
      {
        text: comment.text,
        member_id: other_member.id
      }
    end

    describe 'create comment' do
      let(:expected_keys) { %w(id text member_id created_at updated_at commentable_type commentable_id) }
      let(:response) { post "/api/issues/#{issue.id}/comments", params }
      subject { response.status }

      by_nologin     { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 404 }

      by_participant do
          is_expected.to eq 201
          expect(json_response.keys).to match_array expected_keys
          expect(json_response['member_id']).not_to eq other_member.id
      end

      by_writer do
          is_expected.to eq 201
          expect(json_response.keys).to match_array expected_keys
          expect(json_response['member_id']).not_to eq other_member.id
      end

      by_admin do
        is_expected.to eq 201
        expect(json_response.keys).to match_array expected_keys
        expect(json_response['member_id']).to eq other_member.id
      end
    end

    describe 'create comment with missing text' do
      let(:params_without_text) { params.except(:text) }
      let(:response) { post "/api/issues/#{issue.id}/comments", params_without_text }
      subject { response.status }

      by_participant { is_expected.to eq 400 }
      by_writer      { is_expected.to eq 400 }
      by_admin       { is_expected.to eq 400 }
    end
  end

  describe "PUT, PATCH /api/issues/:issue_id/comments" do
    let!(:comment) { create(:"issue_comment", member: member, commentable: issue) }
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
        by_participant { is_expected.to eq 200 }
        by_writer      { is_expected.to eq 200 }
        by_admin       { is_expected.to eq 200 }
      end

      context 'PUT without text' do
        let(:response) { put "/api/issues/#{issue.id}/comments/#{comment.id}", params.except(:text) }
        subject { response.status }

        by_nologin     { is_expected.to eq 404 }
        by_viewer      { is_expected.to eq 404 }
        by_participant { is_expected.to eq 400 }
        by_writer      { is_expected.to eq 400 }
        by_admin       { is_expected.to eq 400 }
      end

      context 'PATCH without text' do
        let(:response) { patch "/api/issues/#{issue.id}/comments/#{comment.id}", params.except(:text) }
        it_behaves_like 'expected success statuses'

        by_participant { expect(json_response['text']).to eq comment.text }
        by_writer      { expect(json_response['text']).to eq comment.text }
        by_admin       { expect(json_response['text']).to eq comment.text }
      end

      context 'PATCH' do
        describe "participant can't change comment's member_id" do
          let!(:other_member) { create(:member) }
          let(:response) { patch "/api/issues/#{issue.id}/comments/#{comment.id}", { member_id: other_member.id } }

          by_participant { expect(json_response['text']).not_to eq other_member.id }
        end
      end

      context 'PUT' do
        let(:response) { put "/api/issues/#{issue.id}/comments/#{comment.id}", params }
        it_behaves_like 'expected success statuses'

        by_participant { expect(json_response['text']).to eq new_text }
        by_writer      { expect(json_response['text']).to eq new_text }
        by_admin       { expect(json_response['text']).to eq new_text }

        describe "participant can't change comment's member_id" do
          let!(:other_member) { create(:member) }
          let(:response) { put "/api/issues/#{issue.id}/comments/#{comment.id}", params.merge(member_id: other_member.id) }

          by_participant { expect(json_response['text']).not_to eq other_member.id }
        end
      end
    end
  end

  describe "DELETE /api/issues/:issue_id/comments/:id" do
    let!(:comment) { create(:"issue_comment") }

    let(:response) { delete "/api/issues/#{issue.id}/comments/#{comment.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 404 }
    by_participant { is_expected.to eq 404 }
    by_writer      { is_expected.to eq 204 }
    by_admin       { is_expected.to eq 204 }
  end
end
