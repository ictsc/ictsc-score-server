require_relative '../spec_helper.rb'

describe 'Answers' do
  include ApiHelpers

  before(:each) {
    time = DateTime.parse("2017-07-07T21:00:00+09:00")
    allow(DateTime).to receive(:now).and_return(time)
    allow(Config).to receive(:competition_start_at).and_return(time - 3.year)
  }

  describe 'GET /api/answers' do
    let!(:team) { current_member&.team || create(:team) }
    let!(:answers) { create_list(:answer, 2, team: team) }
    let!(:answers_by_other_team) { create_list(:answer, 2, team: create(:team)) }

    let(:response) { get '/api/answers' }
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

  describe 'GET /api/problems/:problems_id/answers' do
    let!(:problem) { create(:problem) }
    let!(:another_problem) { create(:problem) }
    let!(:team) { current_member&.team || create(:team) }
    let!(:answers_t) { create_list(:answer, 2, team: team, problem: problem) }
    let!(:answers_t_by_other_team) { create_list(:answer, 2, team: create(:team), problem: problem) }
    let!(:answers_to_another_problem) { create_list(:answer, 2, team: team, problem: another_problem) }
    let!(:answers_to_another_problem_by_other_team) { create_list(:answer, 2, team: create(:team), problem: another_problem) }

    let(:response) { get "/api/problems/#{problem.id}/answers" }
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

  describe 'GET /api/answers/:id' do
    let!(:team) { current_member&.team || create(:team) }
    let!(:answer) { create(:answer, team: team) }

    let(:response) { get "/api/answers/#{answer.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 200 }
    by_participant { is_expected.to eq 200 }
    by_writer      { is_expected.to eq 200 }
    by_admin       { is_expected.to eq 200 }

    describe 'answer created by other team' do
      let!(:answer) { create(:answer, team: create(:team)) }
      by_participant { is_expected.to eq 404 }
    end

    describe '#keys' do
      let(:expected_keys) { %w(id problem_id team_id text created_at updated_at) }
      subject { json_response.keys }
      by_viewer      { is_expected.to match_array expected_keys }
      by_participant { is_expected.to match_array expected_keys }
      by_writer      { is_expected.to match_array expected_keys }
      by_admin       { is_expected.to match_array expected_keys }
    end
  end

  describe 'POST /api/problems/#{problem.id}/answers' do
    let!(:problem) { create(:problem) }
    let!(:another_problem) { create(:problem) }
    let!(:other_team) { create(:team) }
    let(:answer) { build(:answer, problem: problem) }

    let(:params) do
      {
        text: "hoge",
        problem_id: another_problem.id, # will be ignored
        team_id: other_team.id
      }
    end

    describe 'create answer' do
      let(:expected_keys) { %w(id problem_id team_id text created_at updated_at) }
      let(:response) { post "/api/problems/#{problem.id}/answers", params }
      subject { response.status }

      by_nologin     { is_expected.to eq 404 }
      by_viewer      { is_expected.to eq 403 }
      by_writer      { is_expected.to eq 403 }

      by_participant do
        is_expected.to eq 201
        expect(json_response.keys).to match_array expected_keys
        expect(json_response['team_id']).to eq current_member.team.id
        expect(json_response['team_id']).not_to eq other_team.id
        expect(json_response['problem_id']).to eq problem.id
      end

      by_admin do
        is_expected.to eq 201
        expect(json_response.keys).to match_array expected_keys
        expect(json_response['team_id']).to eq other_team.id
        expect(json_response['problem_id']).to eq problem.id
      end
    end

    describe 'create answer with missing problem_id' do
      let(:params_without_problem_id) { params.except(:problem_id) }
      let(:response) { post "/api/problems/#{problem.id}/answers", params_without_problem_id }
      subject { response.status }

      by_participant { is_expected.to eq 201 }
      by_admin       { is_expected.to eq 201 }
    end

    describe 'create answer with created_at' do
      let(:new_date) { DateTime.parse('2017-07-07T21:00:00+09:00') }
      let(:params_with_created_at) { params.merge(created_at: new_date) }
      let(:response) { post "/api/problems/#{problem.id}/answers", params_with_created_at }
      subject { response.status }

      by_participant do
        is_expected.to eq 201
        expect(DateTime.parse(json_response['created_at'])).to_not eq new_date
      end

      by_admin do
        is_expected.to eq 201
        expect(DateTime.parse(json_response['created_at'])).to_not eq new_date
      end
    end

    describe 'create answer of not opened problem' do
      let!(:unsolved_problem) { create(:problem) }
      let!(:next_problem) { create(:problem, problem_must_solve_before: unsolved_problem) }
      let(:response) { post "/api/problems/#{next_problem.id}/answers", params}
      let(:current_team) { current_member.team || create(:team) }
      let(:params) do
        {
          text: 'hoge',
          problem_id: next_problem.id,
          team_id: current_team.id
        }
      end
      subject { response.status }

      by_participant do
        is_expected.to eq 404
      end

      by_admin do
        is_expected.to eq 201
        expect(json_response['team_id']).to eq current_team.id
        expect(json_response['problem_id']).to eq next_problem.id
      end
    end
  end

  describe 'PUT, PATCH /api/answers' do
    let!(:team) { current_member&.team || create(:team) }
    let!(:answer) { create(:answer, team: team) }
    let!(:new_problem_id) { create(:problem).id }

    describe "edit answer" do
      let(:params) do
        {
          text: "fuga",
          problem_id: new_problem_id,
          team_id: answer.team_id
        }
      end

      shared_examples 'expected statuses for roles having no permission' do
        subject { response.status }

        by_nologin     { is_expected.to eq 404 }
        by_viewer      { is_expected.to eq 404 }
        by_participant { is_expected.to eq 404 }
        by_writer      { is_expected.to eq 404 }
      end

      context 'PUT without team_id' do
        let(:response) { put "/api/answers/#{answer.id}", params.except(:team_id) }
        subject { response.status }
        it_behaves_like 'expected statuses for roles having no permission'

        by_admin       { is_expected.to eq 400 }
      end

      context 'PATCH without team_id' do
        let(:response) { patch "/api/answers/#{answer.id}", params.except(:team_id) }
        subject { response.status }
        it_behaves_like 'expected statuses for roles having no permission'

        by_admin do
          is_expected.to eq 200
          expect(json_response['problem_id']).to eq new_problem_id
        end
      end

      context 'PUT' do
        let(:response) { put "/api/answers/#{answer.id}", params }
        subject { response.status }
        it_behaves_like 'expected statuses for roles having no permission'

        by_admin       { is_expected.to eq 200 }

        by_admin       { expect(json_response['problem_id']).to eq new_problem_id }
      end

      describe 'PUT answer with created_at' do
        let(:new_date) { DateTime.parse('2017-07-07T21:00:00+09:00') }
        let(:params_with_created_at) { params.merge(created_at: new_date) }
        let(:response) { put "/api/answers/#{answer.id}", params_with_created_at }
        subject { response.status }

        by_admin do
          is_expected.to eq 200
          expect(DateTime.parse(json_response['created_at'])).to_not eq new_date
        end
      end
    end
  end

  describe 'DELETE /api/answers/:id' do
    let!(:answer) { create(:answer) }

    let(:response) { delete "/api/answers/#{answer.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 404 }
    by_participant { is_expected.to eq 404 }
    by_writer      { is_expected.to eq 404 }
    by_admin       { is_expected.to eq 204 }
  end
end
