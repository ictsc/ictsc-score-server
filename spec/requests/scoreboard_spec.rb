require_relative '../spec_helper.rb'

describe 'Score board' do
  describe 'GET /api/scoreboard' do
    describe 'response status' do
      let(:response) { get '/api/scoreboard' }
      subject { response.status }

      before(:each) {
        time = DateTime.parse("2017-07-07T21:00:00+09:00")
        allow(DateTime).to receive(:now).and_return(time)
        allow(Setting).to receive(:scoreboard_hide_at).and_return(time + 1.minute)
      }

      by_nologin     { is_expected.to eq 400 }
      by_viewer      { is_expected.to eq 200 }
      by_participant { is_expected.to eq 200 }
      by_writer      { is_expected.to eq 200 }
      by_admin       { is_expected.to eq 200 }
    end

    describe 'response status after scoreboard hide' do
      let(:response) { get '/api/scoreboard' }
      subject { response.status }

      before(:each) {
        time = DateTime.parse("2017-07-07T21:00:00+09:00")
        allow(DateTime).to receive(:now).and_return(time)
        allow(Setting).to receive(:scoreboard_hide_at).and_return(time - 3.year)
      }

      by_nologin     { is_expected.to eq 400 }
      by_viewer      { is_expected.to eq 200 }
      by_participant { is_expected.to eq 400 }
      by_writer      { is_expected.to eq 200 }
      by_admin       { is_expected.to eq 200 }
    end

    describe 'viewer, writer, admin can see all scores' do
      let!(:teams) { create_list(:team, 5) }
      let!(:points) { [10, 50, 80, 90, 100] }
      let!(:scores) {
        teams.zip(points).map do |team, point|
          create(:score, point: point, answer: create(:answer, team: team))
        end
      }

      let(:response) { get '/api/scoreboard' }

      can_get_all_results_block = Proc.new do
        expect(json_response.size).to eq 5
      end

      by_viewer &can_get_all_results_block
      by_writer &can_get_all_results_block
      by_admin &can_get_all_results_block
    end

    # 自分と同点のチームがいる
    # *100, *90, *80, 50, (*50), 10
    describe "participant can't get the team having same points of my team" do
      let!(:teams) { create_list(:team, 5) }
      let!(:points) { [10, 50, 80, 90, 100] }
      let!(:scores) {
        teams.zip(points).map do |team, point|
          create(:score, point: point, answer: create(:answer, team: team))
        end
      }

      let!(:ours_score) {
        create(:score, point: 50, answer: create(:answer, team: current_member.team))
      }

      let(:response) { get '/api/scoreboard' }

      by_participant {
        expect(json_response.map{|s| s['score'] }).to contain_exactly(100, 90, 80, 50)
        expect(json_response).to all(include('score', 'rank', 'team'))
        expect(json_response.find{|s| s['score'] == 50 }.dig('team', 'id')).to eq current_member.team_id
      }
    end

    # 自分より1つ上の点数を持つチームが複数いる
    # *100, *90, *80, *50, *50, (*10)
    describe "participant can get all teams having the 1 rank upper than my team" do
      let!(:teams) { create_list(:team, 5) }
      let!(:points) { [50, 50, 80, 90, 100] }
      let!(:scores) {
        teams.zip(points).map do |team, point|
          create(:score, point: point, answer: create(:answer, team: team))
        end
      }

      let!(:ours_score) {
        create(:score, point: 10, answer: create(:answer, team: current_member.team))
      }

      let(:response) { get '/api/scoreboard' }

      by_participant {
        expect(json_response.map{|s| s['score'] }).to contain_exactly(100, 90, 80, 50, 50, 10)
        expect(json_response.reject{|s| s['score'] == 50 }).to all(include('score', 'rank', 'team'))
      }
    end

    # TOP 3に同点のチームがいる場合にはその全てのチームを返し、実順位が3位のチームまでを全て返す
    # *100, *100, *90, *90, 80, 80, *50, (*10)
    describe "participant can get all teams actually ranked TOP 3" do
      let!(:teams) { create_list(:team, 7) }
      let!(:points) { [50, 80, 80, 90, 90, 100, 100] }
      let!(:scores) {
        teams.zip(points).map do |team, point|
          create(:score, point: point, answer: create(:answer, team: team))
        end
      }

      let!(:ours_score) {
        create(:score, point: 10, answer: create(:answer, team: current_member.team))
      }

      let(:response) { get '/api/scoreboard' }

      by_participant {
        expect(json_response.map{|s| s['score'] }).to contain_exactly(100, 100, 90, 90, 50, 10)
        expect(json_response.reject{|s| s['score'] == 50 }).to all(include('score', 'rank', 'team'))
      }
    end

    # 自分のチームが TOP3 なら TOP3 のみ見える
    # (*100), *90, *80, 50
    describe "participant can only see the TOP 3 teams if my team ranked in TOP 3" do
      let!(:teams) { create_list(:team, 3) }
      let!(:points) { [50, 80, 90] }
      let!(:scores) {
        teams.zip(points).map do |team, point|
          create(:score, point: point, answer: create(:answer, team: team))
        end
      }

      let!(:ours_score) {
        create(:score, point: 100, answer: create(:answer, team: current_member.team))
      }

      let(:response) { get '/api/scoreboard' }

      by_participant {
        expect(json_response.map{|s| s['score'] }).to contain_exactly(100, 90, 80)
        expect(json_response).to all(include('score', 'rank', 'team'))
      }
    end
  end
end
