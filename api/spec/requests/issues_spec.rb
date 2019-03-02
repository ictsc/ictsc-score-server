require_relative '../spec_helper.rb'

describe 'Issues' do
  include ApiHelpers

  before(:each) {
    time = DateTime.parse("2017-07-07T21:00:00+09:00")
    allow(DateTime).to receive(:current).and_return(time)
    allow(Config).to receive(:competition_start_at).and_return(time - 3.year)
  }

  describe 'GET /api/issues' do
    let!(:team) { current_member&.team || create(:team) }
    let!(:issues) { create_list(:issue, 2, team: team) }
    let!(:issues_by_other_team) { create_list(:issue, 2, team: create(:team)) }

    let(:response) { get '/api/issues' }
    subject { response.status }

    by_nologin     { is_expected.to eq 200 }
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
      by_nologin     { is_expected.to eq 0 }
      by_viewer      { is_expected.to eq 4 }
      by_participant { is_expected.to eq 2 }
      by_writer      { is_expected.to eq 4 }
      by_admin       { is_expected.to eq 4 }
    end
  end

  describe 'GET /api/problems/:problems_id/issues' do
    let!(:problem) { create(:problem) }
    let!(:another_problem) { create(:problem) }
    let!(:team) { current_member&.team || create(:team) }
    let!(:issues) { create_list(:issue, 2, team: team, problem: problem) }
    let!(:issues_by_other_team) { create_list(:issue, 2, team: create(:team), problem: problem) }
    let!(:issues_to_another_problem) { create_list(:issue, 2, team: team, problem: another_problem) }
    let!(:issues_to_another_problem_by_other_team) { create_list(:issue, 2, team: create(:team), problem: another_problem) }

    let(:response) { get "/api/problems/#{problem.id}/issues" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 200 }
    by_participant { is_expected.to eq 200 }
    by_writer      { is_expected.to eq 200 }
    by_admin       { is_expected.to eq 200 }

    describe '#size' do
      subject { json_response.size }
      by_viewer      { is_expected.to eq 4 }
      by_participant { is_expected.to eq 2 }
      by_writer      { is_expected.to eq 4 }
      by_admin       { is_expected.to eq 4 }
    end
  end

  describe 'GET /api/issues' do
    let!(:team) { current_member&.team || create(:team) }
    let!(:issues) { create_list(:issue, 2, team: team) }
    let!(:issues_by_other_team) { create_list(:issue, 2, team: create(:team)) }

    let(:response) { get '/api/issues' }
    subject { response.status }

    by_nologin     { is_expected.to eq 200 }
    by_viewer      { is_expected.to eq 200 }
    by_participant { is_expected.to eq 200 }
    by_writer      { is_expected.to eq 200 }
    by_admin       { is_expected.to eq 200 }

    describe '#size' do
      subject { json_response.size }
      by_nologin     { is_expected.to eq 0 }
      by_viewer      { is_expected.to eq 4 }
      by_participant { is_expected.to eq 2 }
      by_writer      { is_expected.to eq 4 }
      by_admin       { is_expected.to eq 4 }
    end
  end

  describe 'GET /api/issues/:id' do
    let!(:team) { current_member&.team || create(:team) }
    let!(:issue) { create(:issue, team: team) }

    let(:response) { get "/api/issues/#{issue.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 200 }
    by_participant { is_expected.to eq 200 }
    by_writer      { is_expected.to eq 200 }
    by_admin       { is_expected.to eq 200 }

    describe 'issue created by other team' do
      let!(:issue) { create(:issue, team: create(:team)) }
      by_participant { is_expected.to eq 404 }
    end

    describe '#keys' do
      let(:expected_keys) { %w(id title closed problem_id created_at updated_at team_id) }
      subject { json_response.keys }
      by_viewer      { is_expected.to match_array expected_keys }
      by_participant { is_expected.to match_array expected_keys }
      by_writer      { is_expected.to match_array expected_keys }
      by_admin       { is_expected.to match_array expected_keys }
    end
  end

  describe 'POST /api/problems/:problem_id/issues' do
    let!(:problem) { create(:problem) }
    let!(:another_problem) { create(:problem) }
    let!(:other_team) { create(:team) }
    let(:issue) { build(:issue, problem: problem) }

    let(:params) do
      {
        title: issue.title,
        closed: false,
        problem_id: another_problem.id, # will be ignored
        team_id: other_team.id
      }
    end

    describe 'create issue' do
      let(:expected_keys) { %w(id title closed problem_id created_at updated_at team_id) }
      let(:response) { post "/api/problems/#{problem.id}/issues", params }
      subject { response.status }

      by_nologin     { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 404 }

      all_success_block = Proc.new do
        is_expected.to eq 201
        expect(json_response.keys).to match_array expected_keys
        expect(json_response['team_id']).to eq other_team.id
        expect(json_response['problem_id']).to eq problem.id
      end

      by_writer &all_success_block
      by_admin &all_success_block

      by_participant do
        is_expected.to eq 201
        expect(json_response.keys).to match_array expected_keys
        expect(json_response['team_id']).not_to eq other_team.id
        expect(json_response['problem_id']).to eq problem.id
      end
    end

    describe 'create issue with missing title' do
      let(:params_without_title) { params.except(:title) }
      let(:response) { post "/api/problems/#{problem.id}/issues", params_without_title }
      subject { response.status }

      by_participant { is_expected.to eq 400 }
      by_writer      { is_expected.to eq 400 }
      by_admin       { is_expected.to eq 400 }
    end
  end

  describe 'PUT, PATCH /api/issues' do
    let!(:team) { current_member&.team || create(:team) }
    let!(:issue) { create(:issue, team: team) }
    let(:new_title) { issue.title + 'nya-' }

    describe "edit issue" do
      let(:params) do
        {
          title: new_title,
          closed: false,
          problem_id: issue.problem_id,
          team_id: issue.team_id
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

      context 'PUT without title' do
        let(:response) { put "/api/issues/#{issue.id}", params.except(:title) }
        subject { response.status }

        by_nologin     { is_expected.to eq 404 }
        by_viewer      { is_expected.to eq 404 }
        by_participant { is_expected.to eq 400 }
        by_writer      { is_expected.to eq 400 }
        by_admin       { is_expected.to eq 400 }
      end

      context 'PATCH without title' do
        let(:response) { patch "/api/issues/#{issue.id}", params.except(:title) }
        it_behaves_like 'expected success statuses'

        by_writer      { expect(json_response['title']).to eq issue.title }
        by_admin       { expect(json_response['title']).to eq issue.title }
      end

      context 'PATCH' do
        describe "participant can't change issue's team_id" do
          let!(:other_team) { create(:team) }
          let(:response) { patch "/api/issues/#{issue.id}", { team_id: other_team.id } }

          by_participant { expect(json_response['title']).not_to eq other_team.id }
        end
      end

      context 'PUT' do
        let(:response) { put "/api/issues/#{issue.id}", params }
        it_behaves_like 'expected success statuses'

        by_writer      { expect(json_response['title']).to eq new_title }
        by_admin       { expect(json_response['title']).to eq new_title }

        describe "participant can't change issue's team_id" do
          let!(:other_team) { create(:team) }
          let(:response) { put "/api/issues/#{issue.id}", params.merge(team_id: other_team.id) }

          by_participant { expect(json_response['title']).not_to eq other_team.id }
        end
      end
    end
  end

  describe 'DELETE /api/issues/:id' do
    let!(:issue) { create(:issue) }

    let(:response) { delete "/api/issues/#{issue.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 404 }
    by_participant { is_expected.to eq 404 }
    by_writer      { is_expected.to eq 204 }
    by_admin       { is_expected.to eq 204 }
  end
end
