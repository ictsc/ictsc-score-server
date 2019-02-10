require_relative '../spec_helper.rb'

describe 'Score board' do
  describe 'GET /api/scoreboard' do
    # answer_reply_delay_secの影響を無くしたいときはcreated_atを指定する
    let(:created_at) { DateTime.now - Setting.answer_reply_delay_sec.seconds * 2 }

    before(:each) {
      now = DateTime.now
      allow(Setting).to receive(:competition_start_at).and_return(now - 1.minute)
      allow(Setting).to receive(:scoreboard_hide_at).and_return(now + 1.minute)
      allow(Setting).to receive(:competition_end_at).and_return(now + 1.minute)
    }


    describe 'response status' do
      let(:response) { get '/api/scoreboard' }
      subject { response.status }

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

    # 自分と同点のチーム複数がいる
    # *100, *90, *80, 50, 50, (*50), 10
    describe "participant can't get the team having same points of my team" do
      let!(:teams) { create_list(:team, 6) }
      let!(:current_team) { current_member.team || create(:team) }
      let!(:points) { [10, 50, 50, 80, 90, 100] }
      let!(:scores) {
        # 全のチームにスコアを登録する
        teams.zip(points).map do |team, point|
          create(:score, point: point, answer: create(:answer, team: team, created_at: created_at))
        end
      }

      let!(:ours_score) { create(:score, point: 50, answer: create(:answer, team: current_team, created_at: created_at)) }
      let(:response) { get '/api/scoreboard' }

      by_participant {
        expect(json_response.map{|s| s['rank'] }).to contain_exactly(1, 2, 3, 4)
        expect(json_response.map{|s| s['score'] }).to contain_exactly(100, 90, 80, 50)
        expect(json_response).to all(include('score', 'rank', 'team'))
        expect(json_response.find{|s| s['score'] == 50 }.dig('team', 'id')).to eq current_member.team_id
      }

      by_admin {
        expect(json_response.map{|s| s['rank'] }).to contain_exactly(1, 2, 3, 4, 4, 4, 7)
        expect(json_response.map{|s| s['score'] }).to contain_exactly(100, 90, 80, 50, 50, 50, 10)
        expect(json_response).to all(include('score', 'rank', 'team'))
      }
    end

    # 自分より1つ上の点数を持つチームが複数いる
    # *100, *90, *80, *50, *50, (*10)
    describe "participant can get all teams having the 1 rank upper than my team" do
      let!(:teams) { create_list(:team, 5) }
      let!(:current_team) { current_member.team || create(:team) }
      let!(:points) { [80, 50, 100, 50, 90] }
      let!(:scores) {
        teams.zip(points).map do |team, point|
          create(:score, point: point, answer: create(:answer, team: team, created_at: created_at))
        end
      }

      let!(:ours_score) {
        create(:score, point: 10, answer: create(:answer, team: current_team, created_at: created_at))
      }

      let(:response) { get '/api/scoreboard' }

      by_participant {
        expect(json_response.map{|s| s['rank'] }).to contain_exactly(1, 2, 3, 4, 4, 6)
        expect(json_response.map{|s| s['score'] }).to contain_exactly(100, 90, 80, 50, 50, 10)
        expect(json_response.reject{|s| s['score'] == 50 }).to all(include('score', 'rank', 'team'))
      }

      by_admin {
        expect(json_response.map{|s| s['rank'] }).to contain_exactly(1, 2, 3, 4, 4, 6)
        expect(json_response.map{|s| s['score'] }).to contain_exactly(100, 90, 80, 50, 50, 10)
        expect(json_response).to all(include('score', 'rank', 'team'))
      }
    end

    # TOP 3に同点のチームがいる場合にはその全てのチームを返し、実順位が3位のチームまでを全て返す
    # *100, *100, *90, *90, 80, 80, *50, (*10)
    describe "participant can get all teams actually ranked TOP 3" do
      let!(:teams) { create_list(:team, 7) }
      let!(:current_team) { current_member.team || create(:team) }
      let!(:points) { [50, 80, 90, 80, 100, 90, 100] }
      let!(:scores) {
        teams.zip(points).map do |team, point|
          create(:score, point: point, answer: create(:answer, team: team, created_at: created_at))
        end
      }

      let(:response) { get '/api/scoreboard' }

      context "when ours team's score is bottom" do
        let!(:ours_score) {
          create(:score, point: 10, answer: create(:answer, team: current_team, created_at: created_at))
        }

        by_participant {
          # 実順位上位3位 + 自分 + 一つ上
          expect(json_response.map{|s| s['rank'] }).to contain_exactly(1, 1, 3, 3, 7, 8)
          expect(json_response.map{|s| s['score'] }).to contain_exactly(100, 100, 90, 90, 50, 10)
          expect(json_response.reject{|s| s['score'] == 50 }).to all(include('score', 'rank', 'team'))
        }

        by_admin {
          expect(json_response.map{|s| s['rank'] }).to contain_exactly(1, 1, 3, 3, 5, 5, 7, 8)
          expect(json_response.map{|s| s['score'] }).to contain_exactly(100, 100, 90, 90, 80, 80, 50, 10)
          expect(json_response).to all(include('score', 'rank', 'team'))
        }
      end

      context "when ours team's score is second from top" do
        let!(:ours_score) {
          create(:score, point: 90, answer: create(:answer, team: current_team, created_at: created_at))
        }

        by_participant {
          expect(json_response.map{|s| s['rank'] }).to contain_exactly(1, 1, 3, 3, 3)
          expect(json_response.map{|s| s['score'] }).to contain_exactly(100, 100, 90, 90, 90)
        }
      end

      context "when ours team's score is third from top" do
        let!(:ours_score) {
          create(:score, point: 80, answer: create(:answer, team: current_team, created_at: created_at))
        }

        by_participant {
          expect(json_response.map{|s| s['rank'] }).to contain_exactly(1, 1, 3, 3, 5)
          expect(json_response.map{|s| s['score'] }).to contain_exactly(100, 100, 90, 90, 80)
        }
      end
    end

    # 自分のチームが TOP3 なら TOP3 のみ見える
    # (*100), *90, *80, 50
    describe "participant can only see the TOP 3 teams if my team ranked in TOP 3" do
      let!(:teams) { create_list(:team, 3) }
      let!(:current_team) { current_member.team || create(:team) }
      let!(:points) { [50, 80, 90] }
      let!(:scores) {
        teams.zip(points).map do |team, point|
          create(:score, point: point, answer: create(:answer, team: team, created_at: created_at))
        end
      }

      let!(:ours_score) {
        create(:score, point: 100, answer: create(:answer, team: current_team, created_at: created_at))
      }

      let(:response) { get '/api/scoreboard' }

      by_participant {
        expect(json_response.map{|s| s['rank'] }).to contain_exactly(1, 2, 3)
        expect(json_response.map{|s| s['score'] }).to contain_exactly(100, 90, 80)
        expect(json_response).to all(include('score', 'rank', 'team'))
      }

      by_admin {
        expect(json_response.map{|s| s['rank'] }).to contain_exactly(1, 2, 3, 4)
        expect(json_response.map{|s| s['score'] }).to contain_exactly(100, 90, 80, 50)
        expect(json_response).to all(include('score', 'rank', 'team'))
      }
    end
  end
end
