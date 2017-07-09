require_relative '../spec_helper.rb'

describe Score do
  include ApiHelpers

  before(:each) {
    time = DateTime.parse("2017-07-07T21:00:00+09:00")
    allow(DateTime).to receive(:now).and_return(time)
    allow(Setting).to receive(:competition_start_at).and_return(time - 3.year)
    allow(Setting).to receive(:answer_reply_delay_sec).and_return(1200)
  }

  describe 'GET /api/scores' do
    let(:team) { current_member&.team || create(:team) }
    let(:answer) { create(:answer, team: team, completed: true, completed_at: DateTime.now) }
    let!(:score) { create(:score, answer: answer) }
    let!(:score_by_other_team) { create(:score, answer: create(:answer)) }

    let(:response) { get '/api/scores' }
    subject { response.status }

    by_nologin     { is_expected.to eq 200 }
    by_viewer      { is_expected.to eq 200 }
    by_participant { is_expected.to eq 200 }
    by_writer      { is_expected.to eq 200 }
    by_admin       { is_expected.to eq 200 }

    describe '#size' do
      subject { json_response.size }
      by_nologin     { is_expected.to eq 0 }
      by_viewer      { is_expected.to eq 2 }
      by_participant { is_expected.to eq 0 }
      by_writer      { is_expected.to eq 2 }
      by_admin       { is_expected.to eq 2 }

      describe 'after Settings.answer_reply_delay_sec' do
        by_participant do
          allow(DateTime).to receive(:now).and_return(score.answer.completed_at + 1500.seconds)
          is_expected.to eq 1
        end
      end
    end
  end

  describe 'GET /api/scores/:id' do
    before do
      allow(Setting).to receive(:first_blood_bonus_percentage).and_return(346)
      allow(Setting).to receive(:bonus_point_for_clear_problem_group).and_return(765)
    end

    let(:team) { current_member&.team || create(:team) }
    let(:problem_group) { create(:problem_group) }
    let(:problem) { create(:problem, problem_group: problem_group) }
    let!(:last_problem_of_problem_group) { create(:problem, problem_group: problem_group) }

    let(:before_answer) { create(:answer, team: team, problem: problem, completed: true, completed_at: DateTime.now - 1.hour) }
    let!(:before_score) { create(:score, point: problem.reference_point - 10, answer: before_answer) }

    let(:answer) { create(:answer, team: team, problem: problem, completed: true, completed_at: DateTime.now) }
    let!(:score) { create(:score, point: problem.reference_point - before_score.point - 1, answer: answer) }

    let(:response) { get "/api/scores/#{score.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 200 }
    by_participant { is_expected.to eq 404 }
    by_writer      { is_expected.to eq 200 }
    by_admin       { is_expected.to eq 200 }

    describe 'after Settings.answer_reply_delay_sec' do
      before { allow(DateTime).to receive(:now).and_return(answer.completed_at + 1500.seconds) }

      by_participant do
        is_expected.to eq 200
      end

      describe '#keys' do
        let(:expected_keys) { %w(id point bonus_point subtotal_point is_firstblood marker_id answer_id created_at updated_at) }
        subject { json_response.keys }

        by_participant do
          is_expected.to match_array expected_keys
        end
      end

      describe '#is_firstblood, #bonus_point, #subtotal_point' do
        by_participant do
          expect(json_response['is_firstblood']).to eq false
          expect(json_response['bonus_point']).to eq 0
          expect(json_response['subtotal_point']).to eq (json_response['point'] + json_response['bonus_point'])
        end
      end
    end

    describe "firstblood answer's score" do
      before { allow(DateTime).to receive(:now).and_return(answer.completed_at + 1500.seconds) }

      let!(:score) { create(:score, point: problem.reference_point - before_score.point, answer: answer) }

      by_participant do
        is_expected.to eq 200
      end

      describe '#is_firstblood, #bonus_point, #subtotal_point' do
        by_participant do
          bonus_point_for_firstblood = problem.perfect_point * Setting.first_blood_bonus_percentage / 100.0

          expect(json_response['is_firstblood']).to eq true
          expect(json_response['bonus_point']).to eq bonus_point_for_firstblood
          expect(json_response['subtotal_point']).to eq (json_response['point'] + json_response['bonus_point'])
        end
      end
    end

    describe "score completes problem group completed" do
      let(:answer_to_last_problem) { create(:answer, team: team, problem: last_problem_of_problem_group, completed: true, completed_at: DateTime.now + 5.minute) }
      let!(:score) { create(:score, point: problem.reference_point - before_score.point, answer: answer) }
      let!(:score_of_answer_to_last_problem) { create(:score, point: last_problem_of_problem_group.reference_point, answer: answer_to_last_problem) }

      let(:response) { get "/api/scores/#{score_of_answer_to_last_problem.id}" }
      subject { response.status }

      before { allow(DateTime).to receive(:now).and_return(answer_to_last_problem.completed_at + 1500.seconds) }

      by_participant do
        is_expected.to eq 200
      end

      describe '#is_firstblood, #bonus_point, #subtotal_point' do
        by_participant do
          bonus_point_for_firstblood = problem.perfect_point * Setting.first_blood_bonus_percentage / 100.0
          bonus_point_for_clear_problem_group = Setting.bonus_point_for_clear_problem_group

          expect(json_response['is_firstblood']).to eq true # because there's no other teams
          expect(json_response['bonus_point']).to eq (bonus_point_for_firstblood + bonus_point_for_clear_problem_group)
          expect(json_response['subtotal_point']).to eq (json_response['point'] + json_response['bonus_point'])
        end
      end
    end

    describe 'score created by other team' do
      let!(:score) { create(:score, answer: create(:answer)) }
      by_participant { is_expected.to eq 404 }
    end

    describe '#keys' do
      let(:expected_keys) { %w(id point bonus_point subtotal_point is_firstblood marker_id answer_id created_at updated_at) }
      subject { json_response.keys }
      by_viewer      { is_expected.to match_array expected_keys }
      by_writer      { is_expected.to match_array expected_keys }
      by_admin       { is_expected.to match_array expected_keys }
    end
  end

  describe 'POST /api/scores' do
    let(:score) { build(:score) }

    let(:params) do
      {
        point: score.point,
        answer_id: score.answer_id,
        marker_id: score.marker_id
      }
    end

    describe 'create score' do
      let(:expected_keys) { %w(id point marker_id answer_id created_at updated_at) }
      let(:response) { post '/api/scores', params }
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

    describe 'create score with missing point' do
      let(:params_without_point) { params.except(:point) }
      let(:response) { post '/api/scores', params_without_point }
      subject { response.status }

      by_writer      { is_expected.to eq 400 }
      by_admin       { is_expected.to eq 400 }
    end
  end

  describe 'PUT, PATCH /api/scores' do
    let!(:team) { current_member&.team || create(:team) }
    let(:marker) do
      if current_member&.role == build(:role, :writer)
        current_member
      else
        create(:member, :writer)
      end
    end
    let!(:score) { create(:score, answer: create(:answer), marker: marker) }
    let(:new_point) { score.point + 10 }

    describe "edit score" do
      let(:params) do
        {
          point: new_point,
          answer_id: score.answer_id,
          marker_id: score.marker_id
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

      context 'PUT without point' do
        let(:response) { put "/api/scores/#{score.id}", params.except(:point) }
        subject { response.status }

        by_nologin     { is_expected.to eq 404 }
        by_viewer      { is_expected.to eq 404 }
        by_participant { is_expected.to eq 404 }
        by_writer      { is_expected.to eq 400 }
        by_admin       { is_expected.to eq 400 }
      end

      context 'PATCH without point' do
        let(:response) { patch "/api/scores/#{score.id}", params.except(:point) }
        it_behaves_like 'expected success statuses'

        by_writer do
          expect(json_response['point']).to eq score.point
          expect(json_response['marker_id']).to eq current_member.id
        end

        by_admin       { expect(json_response['point']).to eq score.point }
      end

      context 'PUT' do
        let(:response) { put "/api/scores/#{score.id}", params }
        it_behaves_like 'expected success statuses'

        by_writer do
          expect(json_response['point']).to eq new_point
          expect(json_response['marker_id']).to eq current_member.id
        end

        by_admin       { expect(json_response['point']).to eq new_point }
      end
    end
  end

  describe 'DELETE /api/scores/:id' do
    let!(:score) { create(:score) }

    let(:response) { delete "/api/scores/#{score.id}" }
    subject { response.status }

    by_nologin     { is_expected.to eq 404 }
    by_viewer      { is_expected.to eq 404 }
    by_participant { is_expected.to eq 404 }
    by_writer      { is_expected.to eq 404 }
    by_admin       { is_expected.to eq 204 }

    describe "can't delete score other's marked" do
      let!(:score) { create(:score, marker: current_member) }

      by_writer      { is_expected.to eq 204 }
    end
  end
end
