require_relative '../spec_helper.rb'

describe Problem do
  include ApiHelpers

  before(:each) {
    time = DateTime.now
    allow(DateTime).to receive(:now).and_return(time)
    allow(Setting).to receive(:competition_start_at).and_return(time - 3.year)
  }

  let!(:delayed) { DateTime.now - Setting.answer_reply_delay_sec.seconds }

  describe 'GET /api/problems' do
    let!(:problem) { create(:problem) }
    let!(:next_problem) { create(:problem, problem_must_solve_before: problem) }
    let!(:team_private_problem) { create(:problem, problem_must_solve_before: problem, team_private: true) }
    let!(:team_private_problem_no_deps) { create(:problem, problem_must_solve_before: nil, team_private: true) }

    let(:expected_keys) { %w(id title text solved_teams_count creator_id created_at updated_at problem_must_solve_before_id reference_point perfect_point problem_group_ids order team_private secret_text) }
    let(:expected_keys_for_participant_opened) { expected_keys - %w(creator_id reference_point secret_text) }
    let(:expected_keys_for_participant_not_opened) { expected_keys_for_participant_opened - %w(title text perfect_point) }

    let(:response) { get '/api/problems' }
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
      by_participant { is_expected.to eq 4 }
      by_writer      { is_expected.to eq 4 }
      by_admin       { is_expected.to eq 4 }
    end

    describe '#keys for problem' do
      let(:json_response_problem) { json_response.find{|p| p['id'] == problem.id } }
      subject { json_response_problem.keys }

      by_viewer      { is_expected.to match_array expected_keys }
      by_participant { is_expected.to match_array expected_keys_for_participant_opened }
      by_writer      { is_expected.to match_array expected_keys }
      by_admin       { is_expected.to match_array expected_keys }

      describe '#solved_teams_count before reply_delay_sec' do
        let!(:score_by_other_team_a) { create(:score, solved: true,  answer: create(:answer, problem: problem)) } # solved
        let!(:score_by_other_team_b) { create(:score, solved: false, answer: create(:answer, problem: problem)) } # not solved
        subject { json_response_problem['solved_teams_count'] }

        by_viewer      { is_expected.to eq 1 }
        by_participant { is_expected.to eq 0 }
        by_writer      { is_expected.to eq 1 }
        by_admin       { is_expected.to eq 1 }
      end

      describe '#solved_teams_count after reply_delay_sec' do
        let!(:score_by_other_team_a) { create(:score, solved: true,  answer: create(:answer, problem: problem, created_at: delayed)) } # solved
        let!(:score_by_other_team_b) { create(:score, solved: false, answer: create(:answer, problem: problem, created_at: delayed)) } # not solve
        subject { json_response_problem['solved_teams_count'] }

        by_viewer      { is_expected.to eq 1 }
        by_participant { is_expected.to eq 1 }
        by_writer      { is_expected.to eq 1 }
        by_admin       { is_expected.to eq 1 }
      end
    end

    describe "#keys for problem participant haven't solve problem before" do
      let(:json_response_next_problem) { json_response.find{|p| p['id'] == next_problem.id } }
      subject { json_response_next_problem.keys }

      by_participant { is_expected.to match_array expected_keys_for_participant_not_opened }
    end

    describe "#keys of team private problem" do
      let(:json_response_team_private_problem) { json_response.find{|p| p['id'] == team_private_problem.id } }
      subject { json_response_team_private_problem.keys }

      let(:solve_problem_by_own_team) { create(:score, solved: true, answer: create(:answer, problem: problem, team: current_member.team, created_at: delayed)) }
      let(:solve_problem_by_other_team) { create(:score, solved: true,  answer: create(:answer, problem: problem, created_at: delayed)) } # solved

      describe "when it has not dependency problem" do
        let(:json_response_team_private_problem) { json_response.find{|p| p['id'] == team_private_problem_no_deps.id } }
        by_participant { is_expected.to match_array expected_keys_for_participant_opened }
      end

      describe "when its dependency problem has been solved by own team" do
        by_participant {
          solve_problem_by_own_team
          is_expected.to match_array expected_keys_for_participant_opened
        }
      end

      describe "when its dependency problem has been solved by other teams" do
        by_participant {
          solve_problem_by_other_team
          is_expected.to match_array expected_keys_for_participant_not_opened
        }
      end

      describe "when its dependency problem has not been solved by every teams" do
        by_participant { is_expected.to match_array expected_keys_for_participant_not_opened }
      end
    end
  end

  describe 'GET /api/problems/:id' do
    let!(:problem) { create(:problem) }
    let!(:next_problem) { create(:problem, problem_must_solve_before: problem) }
    let!(:team_private_problem) { create(:problem, problem_must_solve_before: problem, team_private: true) }
    let!(:team_private_problem_no_deps) { create(:problem, problem_must_solve_before: nil, team_private: true) }

    let(:response) { get "/api/problems/#{problem.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 200 }
    by_writer      { is_expected.to eq 200 }
    by_admin       { is_expected.to eq 200 }

    describe "problem have solved by other team before problem must solve" do
      let(:team) { create(:team) }
      let(:response) { get "/api/problems/#{next_problem.id}" }
      let!(:score) { create(:score, solved: true, answer: create(:answer, problem: problem, team: team, created_at: created_at)) }
      subject { response.status }


      describe '(answer created at now)' do
        let!(:created_at) { DateTime.now }
        by_participant { is_expected.to eq 404 }
      end

      describe '(answer created at before)' do
        let!(:created_at) { delayed }
        by_participant { is_expected.to eq 200 }
      end
    end

    describe "problem haven't solved before problem must solve" do
      let!(:problem) { create(:problem) }
      let(:response) { get "/api/problems/#{next_problem.id}" }
      subject { response.status }

      by_participant { is_expected.to eq 404 }
    end

    describe "team private problem" do
      let(:response) { get "/api/problems/#{team_private_problem.id}" }
      subject { response.status }

      let(:solve_problem_by_own_team) { create(:score, solved: true, answer: create(:answer, problem: problem, team: current_member.team, created_at: delayed)) }
      let(:solve_problem_by_other_team) { create(:score, solved: true,  answer: create(:answer, problem: problem, created_at: delayed)) } # solved

      describe "can solve if it has not dependency problem" do
        let(:response) { get "/api/problems/#{team_private_problem_no_deps.id}" }
        by_participant { is_expected.to eq 200 }
      end

      describe "can solve if own team has solved its dependency problem" do
        by_participant {
          solve_problem_by_own_team
          is_expected.to eq 200
        }
      end

      describe "cannot solve even if other teams have solved its dependency problem" do
        by_participant {
          solve_problem_by_other_team
          is_expected.to eq 404
        }
      end

      describe "cannot solve if every team has not solved its dependency problem" do
        by_participant { is_expected.to eq 404 }
      end
    end

    describe '#keys' do
      let(:expected_keys) { %w(id title text solved_teams_count creator_id created_at updated_at problem_must_solve_before_id reference_point perfect_point problem_group_ids order team_private secret_text) }
      let(:expected_keys_for_participant_opened) { expected_keys - %w(creator_id reference_point secret_text) }
      subject { json_response.keys }
      by_viewer      { is_expected.to match_array expected_keys }
      by_writer      { is_expected.to match_array expected_keys }
      by_admin       { is_expected.to match_array expected_keys }
      by_participant { is_expected.to match_array expected_keys_for_participant_opened }
    end

    describe '#solved_teams_count before reply_delay_sec' do
      let!(:score_by_other_team_a) { create(:score, solved: true,  answer: create(:answer, problem: problem)) } # solved
      let!(:score_by_other_team_b) { create(:score, solved: false, answer: create(:answer, problem: problem)) } # not solved
      subject { json_response['solved_teams_count'] }

      by_viewer      { is_expected.to eq 1 }
      by_participant { is_expected.to eq 0 }
      by_writer      { is_expected.to eq 1 }
      by_admin       { is_expected.to eq 1 }
    end

    describe '#solved_teams_count after reply_delay_sec' do
      let!(:score_by_other_team_a) { create(:score, solved: true,  answer: create(:answer, problem: problem, created_at: delayed)) } # solved
      let!(:score_by_other_team_b) { create(:score, solved: false, answer: create(:answer, problem: problem, created_at: delayed)) } # not solved
      subject { json_response['solved_teams_count'] }

      by_viewer      { is_expected.to eq 1 }
      by_participant { is_expected.to eq 1 }
      by_writer      { is_expected.to eq 1 }
      by_admin       { is_expected.to eq 1 }
    end
  end

  describe 'POST /api/problems' do
    let(:problem) { build(:problem) }

    let(:params) do
      {
        title: problem.title,
        text: problem.text,
        secret_text: '',
        creator_id: problem.creator_id,
        reference_point: problem.reference_point,
        perfect_point: problem.perfect_point,
        problem_group_ids: problem.problem_group_ids,
        order: 0,
        team_private: false,
      }
    end

    describe 'create problem' do
      let(:expected_keys) { %w(id title text creator_id created_at updated_at problem_must_solve_before_id reference_point perfect_point problem_group_ids order team_private secret_text) }
      let(:response) { post '/api/problems', params }
      subject { response.status }

      by_nologin     { is_expected.to eq 403 }
      by_viewer      { is_expected.to eq 403 }
      by_participant { is_expected.to eq 403 }

      all_success_block = Proc.new do
        is_expected.to eq 201
        expect(json_response.keys).to match_array expected_keys
      end

      by_writer &all_success_block
      by_admin &all_success_block
    end

    describe 'create problem with missing title' do
      let(:params_without_title) { params.except(:title) }
      let(:response) { post '/api/problems', params_without_title }
      subject { response.status }

      by_writer      { is_expected.to eq 400 }
      by_admin       { is_expected.to eq 400 }
    end
  end

  describe 'PUT, PATCH /api/problems' do
    let(:creator) do
      if current_member&.role == build(:role, :writer)
        current_member
      else
        build(:member, :writer)
      end
    end
    let!(:problem) { create(:problem, creator: creator) }
    let(:new_title) { problem.title + 'nya-' }

    describe "edit problem" do
      let(:params) do
        {
          title: new_title,
          text: problem.text,
          secret_text: '',
          creator_id: problem.creator_id,
          reference_point: problem.reference_point,
          perfect_point: problem.perfect_point,
          problem_group_ids: problem.problem_group_ids,
          problem_must_solve_before_id: problem.problem_must_solve_before_id,
          order: 0,
          team_private: false,
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

      context 'PUT without title' do
        let(:response) { put "/api/problems/#{problem.id}", params.except(:title) }
        subject { response.status }

        by_nologin     { is_expected.to eq 404 }
        by_viewer      { is_expected.to eq 404 }
        by_participant { is_expected.to eq 404 }
        by_writer      { is_expected.to eq 400 }
        by_admin       { is_expected.to eq 400 }
      end

      context 'PATCH without title' do
        let(:response) { patch "/api/problems/#{problem.id}", params.except(:title) }
        it_behaves_like 'expected success statuses'

        by_writer      { expect(json_response['title']).to eq problem.title }
        by_admin       { expect(json_response['title']).to eq problem.title }
      end

      context 'PUT' do
        let(:response) { put "/api/problems/#{problem.id}", params }
        it_behaves_like 'expected success statuses'

        by_writer      { expect(json_response['title']).to eq new_title }
        by_admin       { expect(json_response['title']).to eq new_title }
      end
    end
  end

  describe 'DELETE /api/problems/:id' do
    let(:creator) do
      if current_member&.role == build(:role, :writer)
        current_member
      else
        build(:member, :writer)
      end
    end
    let!(:problem) { create(:problem, creator: creator) }
    let(:response) { delete "/api/problems/#{problem.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 404 }
    by_participant { is_expected.to eq 404 }
    by_writer      { is_expected.to eq 204 }
    by_admin       { is_expected.to eq 204 }

    describe "can't delete problems created by others" do
      let!(:problem) { create(:problem) }
      let(:response) { delete "/api/problems/#{problem.id}" }
      subject { response.status }

      by_writer      { is_expected.to eq 404 }
    end
  end
end
