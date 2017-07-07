require_relative '../spec_helper.rb'

describe Answer do
  include ApiHelpers

  describe 'GET /answers' do
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

  describe 'GET /answers/:id' do
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
      let(:expected_keys) { %w(id problem_id team_id completed completed_at created_at updated_at) }
      subject { json_response.keys }
      by_viewer      { is_expected.to match_array expected_keys }
      by_participant { is_expected.to match_array expected_keys }
      by_writer      { is_expected.to match_array expected_keys }
      by_admin       { is_expected.to match_array expected_keys }
    end
  end

  describe 'POST /api/answers' do
    let!(:other_team) { create(:team) }
    let(:answer) { build(:answer) }

    let(:params) do
      {
        completed: false,
        problem_id: answer.problem_id,
        team_id: other_team.id
      }
    end

    describe 'create answer' do
      let(:expected_keys) { %w(id problem_id team_id completed completed_at created_at updated_at) }
      let(:response) { post '/api/answers', params }
      subject { response.status }

      by_nologin     { is_expected.to eq 403 }
      by_viewer      { is_expected.to eq 403 }
      by_writer      { is_expected.to eq 403 }

      by_participant do
        is_expected.to eq 201
        expect(json_response.keys).to match_array expected_keys
        expect(json_response['team_id']).not_to eq other_team.id
      end

      by_admin do
        is_expected.to eq 201
        expect(json_response.keys).to match_array expected_keys
        expect(json_response['team_id']).to eq other_team.id
      end
    end

    describe 'create answer with missing problem_id' do
      let(:params_without_problem_id) { params.except(:problem_id) }
      let(:response) { post '/api/answers', params_without_problem_id }
      subject { response.status }

      by_participant { is_expected.to eq 400 }
      by_admin       { is_expected.to eq 400 }
    end
  end

  describe 'PUT, PATCH /api/answers' do
    let!(:team) { current_member&.team || create(:team) }
    let!(:answer) { create(:answer, team: team) }
    let!(:new_problem_id) { create(:problem).id }

    describe "edit answer" do
      let(:params) do
        {
          completed: true,
          problem_id: new_problem_id,
          team_id: answer.team_id
        }
      end

      shared_examples 'expected statuses for roles having no permission' do
        subject { response.status }

        by_nologin     { is_expected.to eq 404 }
        by_viewer      { is_expected.to eq 404 }
        by_writer      { is_expected.to eq 404 }
      end

      context 'PUT without team_id' do
        let(:response) { put "/api/answers/#{answer.id}", params.except(:team_id) }
        subject { response.status }
        it_behaves_like 'expected statuses for roles having no permission'

        by_participant { is_expected.to eq 404 }
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

      context 'PATCH' do # by participant
        describe "can't make answer completed with no comments" do
          let(:response) { patch "/api/answers/#{answer.id}", { completed: true } }
          subject { response.status }

          by_participant do
            is_expected.to eq 400
          end
        end

        describe "can make answer completed with comments" do
          let!(:comment) { create(:answer_comment, commentable: answer) }
          let(:response) { patch "/api/answers/#{answer.id}", { completed: true } }
          subject { response.status }

          by_participant do
            is_expected.to eq 200
            expect(json_response['completed']).to eq true
          end
        end

        describe "can make answer completed within completed another answer of same problem in `Setting.answer_reply_delay_sec` seconds" do
          before do
            time = DateTime.parse("2017-07-07T21:00:00+09:00")
            allow(DateTime).to receive(:now).and_return(time)
            allow(Setting).to receive(:answer_reply_delay_sec).and_return(60 * 60 * 24 * 365 * 3) # 3 year
          end

          let!(:another_answer) do 
            create(:answer, 
              team: team, 
              problem: answer.problem, 
              comments: [create(:answer_comment)], 
              completed: true,
              completed_at: DateTime.now - 2.year)
          end
          let!(:comment) { create(:answer_comment, commentable: answer) }
          let(:response) { patch "/api/answers/#{answer.id}", { completed: true } }
          subject { response.status }

          by_participant do
            is_expected.to eq 400
          end
        end

        describe "can't make answer not completed" do
          let!(:answer) { create(:answer, team: team, completed: true) }
          let!(:comment) { create(:answer_comment, commentable: answer) }
          let(:response) { patch "/api/answers/#{answer.id}", { completed: false } }
          subject { response.status }

          by_participant do
            is_expected.to eq 400
          end
        end

        describe "can't change answer's team_id" do
          let!(:other_team) { create(:team) }
          let(:response) { patch "/api/answers/#{answer.id}", { team_id: other_team.id } }
          subject { response.status }

          by_participant { is_expected.to eq 400 }
        end
      end

      context 'PUT' do
        let(:response) { put "/api/answers/#{answer.id}", params }
        subject { response.status }
        it_behaves_like 'expected statuses for roles having no permission'

        by_participant { is_expected.to eq 404 }
        by_admin       { is_expected.to eq 200 }

        by_admin       { expect(json_response['problem_id']).to eq new_problem_id }
      end
    end
  end

  describe 'DELETE /answers/:id' do
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
