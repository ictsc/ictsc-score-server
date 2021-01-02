# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'scoreboards', type: :request do
  # クエリのレスポンスでteamの情報も取得する際に利用する

  # テストの前提とする設定
  # 本戦を想定した設定
  # 容易に変更してはいけない
  before(:each) do
    # 条件によってスコアボードが非表示になる系
    Config.competition_section1_start_at  = Time.zone.parse('2012-09-03 10:00:00 +0900')
    Config.competition_section1_end_at    = Time.zone.parse('2112-09-03 12:00:00 +0900')
    Config.scoreboard_hide_at             = Time.zone.parse('2112-09-03 12:00:00 +0900')
    Config.competition_stop               = false
    Config.hide_all_score                 = false

    # 表示系
    Config.scoreboard_top                 = 3
    Config.scoreboard_display_top_team    = true
    Config.scoreboard_display_top_score   = true
    Config.scoreboard_display_above_team  = false
    Config.scoreboard_display_above_score = true

    # その他
    Config.realtime_grading               = true
    Config.grading_delay_sec              = 20.minutes.to_i
    Config.penalty_weight                 = -10
  end

  describe 'クエリの戻り値の仕様' do
    shared_examples 'basic' do
      let!(:scoreboard_non_composite_field_keys) { GraphqlQueryBuilder.reject_composite_fields(Types::ScoreboardType.fields).keys }

      fields = GraphqlQueryBuilder.fields_to_query(fields: Types::ScoreboardType.fields)
      it "#{fields}を取得可能" do
        post_query
        expect(response_json).not_to have_gql_errors
        expect(response_gql.size).to eq(2)
        expect(response_gql.first.keys).to match_array(scoreboard_non_composite_field_keys)
      end
    end

    shared_examples 'with team' do
      let!(:team_non_composite_field_keys) { GraphqlQueryBuilder.reject_composite_fields(Types::TeamType.fields).keys }

      it 'teamを取得可能' do
        post_query(nest_fields: ['team'])
        expect(response_json).not_to have_gql_errors
        expect(response_gql.size).to eq(2)
        expect(response_gql.first).to have_key('team')
        expect(response_gql.first.fetch('team').keys).to match_array(team_non_composite_field_keys)
      end
    end

    context_as_staff    { include_examples 'basic' }
    context_as_audience { include_examples 'basic' }
    context_as_player1  { include_examples 'basic' }

    context_as_staff    { include_examples 'with team' }
    context_as_audience { include_examples 'with team' }
    context_as_player1  { include_examples 'with team' }
  end

  context 'when 競技時間外' do
    before(:each) do
      Config.competition_section1_start_at = Time.zone.parse('2112-09-03 10:00:00 +0900')
    end

    shared_examples 'レコード数0' do
      it 'レコード数0' do
        post_query
        expect(response_json).not_to have_gql_errors
        expect(response_gql.size).to eq(0)
      end
    end

    shared_examples 'レコード数2' do
      it 'レコード数2' do
        expect(Team.player_without_team99.count).to eq(2)

        post_query
        expect(response_json).not_to have_gql_errors
        expect(response_gql.size).to eq(2)
      end
    end

    context_as_staff    { include_examples 'レコード数2' }
    context_as_audience { include_examples 'レコード数0' }
    context_as_player1  { include_examples 'レコード数0' }
  end

  context 'when 競技強制中断中(Config.competition_stop == true)' do
    before(:each) do
      Config.competition_stop = true
      create(:answer, problem: create(:problem), team: player1)
        .grade(percent: 100)
    end

    shared_examples 'レコード数0' do
      it 'レコード数0' do
        post_query
        expect(response_json).not_to have_gql_errors
        expect(response_gql.size).to eq(0)
      end
    end

    shared_examples 'レコード数2' do
      it 'レコード数2' do
        expect(Team.player_without_team99.count).to eq(2)

        post_query
        expect(response_json).not_to have_gql_errors
        expect(response_gql.size).to eq(2)
      end
    end

    context_as_staff    { include_examples 'レコード数2' }
    context_as_audience { include_examples 'レコード数0' }
    context_as_player1  { include_examples 'レコード数0' }
  end

  context 'when スコア非開示中(Config.hide_all_score == true)' do
    before(:each) do
      Config.hide_all_score = true
      create(:answer, :created_at_after_delay, problem: create(:problem), team: player1)
        .grade(percent: 100)
    end

    shared_examples 'レコード数0' do
      it 'レコード数0' do
        expect(Team.player_without_team99.count).to eq(2)
        expect(Score.count).to eq(1)

        post_query
        expect(response_json).not_to have_gql_errors
        expect(response_gql.size).to eq(0)
      end
    end

    shared_examples 'レコード数2' do
      it 'レコード数2' do
        expect(Team.player_without_team99.count).to eq(2)
        expect(Score.count).to eq(1)

        post_query
        expect(response_json).not_to have_gql_errors
        expect(response_gql.size).to eq(2)
      end
    end

    context_as_staff    { include_examples 'レコード数2' }
    context_as_audience { include_examples 'レコード数2' }
    context_as_player1  { include_examples 'レコード数0' }
  end

  context 'when 問題が公開期間外(Problem#open_at)' do
    let(:closed_problem) { create(:problem, open_at: (Time.current - 2.seconds)..(Time.current - 1.second)) }

    before(:each) do
      create(:answer, :created_at_after_delay, problem: closed_problem, team: player1)
        .grade(percent: 100)
    end

    shared_examples 'all' do
      it 'スコアボードには反映される' do
        # 前提条件: 競技時間内だが、問題は非公開
        expect(Config.competition?).to eq(true)
        expect(closed_problem.body.readable?(team: player1)).to eq(false)

        post_query
        expect(response_json).not_to have_gql_errors
        expect(response_gql.size).to eq(2)
        expect(response_gql).to match_array([
                                              include({ 'rank' => 1, 'teamId' => player1.id, 'score' => closed_problem.body.perfect_point }),
                                              include({ 'rank' => 2, 'teamId' => player2.id, 'score' => 0 })
                                            ])
      end
    end

    context_as_staff    { include_examples 'all' }
    context_as_audience { include_examples 'all' }
    context_as_player1  { include_examples 'all' }
  end

  describe 'team99のレコードの挙動' do
    before(:each) do
      problem = create(:problem)

      create(:answer, :created_at_after_delay, problem: problem, team: team99)
        .grade(percent: 100)
      create(:answer, :created_at_after_delay, problem: problem, team: player1)
        .grade(percent: 100)
    end

    shared_examples 'not team99' do
      it 'team99を除いたランキングが見える,player2は2位' do
        post_query
        expect(response_json).not_to have_gql_errors
        expect(response_gql.size).to eq(2)
        expect(response_gql).to match_array([
                                              include({ 'rank' => 1, 'teamId' => player1.id }),
                                              include({ 'rank' => 2, 'teamId' => player2.id })
                                            ])
      end
    end

    shared_examples 'team99' do
      it 'team99を含めたランキングが見える,player2は3位' do
        post_query
        expect(response_json).not_to have_gql_errors
        expect(response_gql.size).to eq(3)
        expect(response_gql).to match_array([
                                              include({ 'rank' => 1, 'teamId' => player1.id }),
                                              include({ 'rank' => 3, 'teamId' => player2.id }),
                                              include({ 'rank' => 1, 'teamId' => team99.id })
                                            ])
      end
    end

    context_as_staff    { include_examples 'not team99' }
    context_as_audience { include_examples 'not team99' }
    context_as_player1  { include_examples 'not team99' }
    context_as_player2  { include_examples 'not team99' }
    context_as_team99   { include_examples 'team99' }
  end

  describe 'ランキングの仕様' do
    context 'when player1がbegginer' do
      before(:each) do
        player1.update(beginner: true)

        create(:answer, problem: create(:problem), team: player1)
          .grade(percent: 100)
      end

      shared_examples 'not player' do
        it 'beginner毎にランキング,全レコード取得' do
          expect(player1.beginner).not_to eq(player2.beginner)
          expect(Score.count).to eq(1)

          post_query(nest_fields: ['team'])
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(2)
          expect(response_gql).to match_array([
                                                include({ 'rank' => 1, 'team' => include({ 'beginner' => true }) }),
                                                include({ 'rank' => 1, 'team' => include({ 'beginner' => false }) })
                                              ])
        end
      end

      shared_examples 'player' do
        it 'beginner毎にランキング,自分のbeginnerと同じレコードのみ取得' do
          expect(player1.beginner).not_to eq(player2.beginner)
          expect(Score.count).to eq(1)

          post_query(nest_fields: ['team'])
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(1)
          expect(response_gql.first).to include({ 'rank' => 1, 'team' => include({ 'id' => current_team.id, 'beginner' => current_team.beginner }) })
        end
      end

      context_as_staff    { include_examples 'not player' }
      context_as_audience { include_examples 'not player' }
      context_as_player1  { include_examples 'player' }
      context_as_player2  { include_examples 'player' }
    end

    context 'when 同点(scoreのみ同じ)' do
      shared_examples 'all1' do
        before(:each) do
          problem1 = create(:problem)
          problem2 = create(:problem)

          create(:answer, :created_at_after_delay, problem: problem1, team: player1)
            .grade(percent: 100)
          create(:answer, :created_at_after_delay, problem: problem2, team: player1)
            .grade(percent: 100)
          create(:answer, :created_at_after_delay, problem: problem1, team: player2)
            .grade(percent: 100)
        end

        it '満点問題数を考慮する' do
          expect(Score.count).to eq(3)

          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(2)
          expect(response_gql).to match_array([
                                                include({ 'rank' => 1, 'teamId' => player1.id }),
                                                include({ 'rank' => 2, 'teamId' => player2.id })
                                              ])
        end
      end

      shared_examples 'all2' do
        before(:each) do
          problem = create(:problem)

          create(:answer, :created_at_after_delay, problem: problem, team: player1)
            .grade(percent: 100)
          create(:answer, :created_at_after_delay, problem: problem, team: player1)
            .grade(percent: 100)
          create(:answer, :created_at_after_delay, problem: problem, team: player2)
            .grade(percent: 100)
        end

        it '同一問題の満点数は考慮しない' do
          expect(Score.count).to eq(3)

          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(2)
          expect(response_gql).to match_array([
                                                include({ 'rank' => 1, 'teamId' => player1.id }),
                                                include({ 'rank' => 1, 'teamId' => player2.id })
                                              ])
        end
      end

      context_as_staff    { include_examples 'all1' }
      context_as_audience { include_examples 'all1' }
      context_as_player1  { include_examples 'all1' }

      context_as_staff    { include_examples 'all2' }
      context_as_audience { include_examples 'all2' }
      context_as_player1  { include_examples 'all2' }
    end

    describe 'when 完全同点(scoreとperfect_countが同じ)' do
      before(:each) do
        # 全チーム見れるようにする
        Config.scoreboard_top = 6

        problem = create(:problem)

        # 順位が1,1,1,4,4,6になる網羅的なパターン
        create(:answer, :created_at_after_delay, problem: problem, team: player1)
          .grade(percent: 100)
        create(:answer, :created_at_after_delay, problem: problem, team: player2)
          .grade(percent: 100)
        create(:answer, :created_at_after_delay, problem: problem, team: player3)
          .grade(percent: 100)
        create(:answer, :created_at_after_delay, problem: problem, team: player4)
          .grade(percent: 50)
        create(:answer, :created_at_after_delay, problem: problem, team: player5)
          .grade(percent: 50)
      end

      # チーム作成は重い
      let!(:player3) { create(:team, :player, name: 'player3', beginner: false) }
      let!(:player4) { create(:team, :player, name: 'player4', beginner: false) }
      let!(:player5) { create(:team, :player, name: 'player5', beginner: false) }
      let!(:player6) { create(:team, :player, name: 'player6', beginner: false) }

      shared_examples 'all' do
        it '同じ順位になり次の順位はその分ずれる' do
          expect(Team.player_without_team99.count).to eq(6)
          expect(Score.count).to eq(5)

          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(6)
          expect(response_gql).to match_array([
                                                include({ 'rank' => 1, 'teamId' => player1.id }),
                                                include({ 'rank' => 1, 'teamId' => player2.id }),
                                                include({ 'rank' => 1, 'teamId' => player3.id }),
                                                include({ 'rank' => 4, 'teamId' => player4.id }),
                                                include({ 'rank' => 4, 'teamId' => player5.id }),
                                                include({ 'rank' => 6, 'teamId' => player6.id })
                                              ])
        end
      end

      context_as_staff    { include_examples 'all' }
      context_as_audience { include_examples 'all' }
      context_as_player1  { include_examples 'all' }
    end
  end

  describe 'スコア計算の仕様' do
    context 'when 無解答' do
      shared_examples 'all' do
        it '全チーム0点&1位' do
          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(2)
          expect(response_gql).to all(include({ 'rank' => 1, 'score' => 0 }))
        end
      end

      context_as_staff    { include_examples 'all' }
      context_as_audience { include_examples 'all' }
      context_as_player1  { include_examples 'all' }
    end

    context 'when 未採点解答のみ' do
      before(:each) do
        create(:answer, problem: create(:problem), team: player1)
      end

      shared_examples 'all' do
        it '全チーム0点&1位' do
          expect(Answer.count).to eq(1)
          expect(Score.count).to eq(0)

          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(2)
          expect(response_gql).to all(include({ 'rank' => 1, 'score' => 0 }))
        end
      end

      context_as_staff    { include_examples 'all' }
      context_as_audience { include_examples 'all' }
      context_as_player1  { include_examples 'all' }
    end

    context 'when 採点済み解答がある' do
      before(:each) do
        answer.grade(percent: 100)
      end

      let(:answer) { create(:answer, :created_at_after_delay, problem: create(:problem), team: player1) }

      shared_examples 'all' do
        it 'player1の順位とスコアが上昇' do
          expect(Team.player_without_team99.count).to eq(2)

          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(2)
          expect(response_gql).to match_array([
                                                include({ 'teamId' => player1.id, 'rank' => 1, 'score' => answer.score.point }),
                                                include({ 'teamId' => player2.id, 'rank' => 2, 'score' => 0 })
                                              ])
        end
      end

      context_as_staff    { include_examples 'all' }
      context_as_audience { include_examples 'all' }
      context_as_player1  { include_examples 'all' }
      context_as_player2  { include_examples 'all' }
    end

    context 'when 採点済み遅延中解答のみ' do
      before(:each) do
        answer.grade(percent: 100)
      end

      let(:answer) { create(:answer, problem: create(:problem), team: player1) }

      shared_examples 'not player' do
        it 'スコアに反映' do
          expect(Score.count).to eq(1)

          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(2)
          expect(response_gql).to match_array([
                                                include({ 'teamId' => player1.id, 'rank' => 1, 'score' => answer.score.point }),
                                                include({ 'teamId' => player2.id, 'rank' => 2, 'score' => 0 })
                                              ])
        end
      end

      shared_examples 'player' do
        it 'スコアに未反映' do
          expect(Score.count).to eq(1)

          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(2)
          expect(response_gql).to all(include({ 'rank' => 1, 'score' => 0 }))
        end
      end

      context_as_staff    { include_examples 'not player' }
      context_as_audience { include_examples 'not player' }
      context_as_player1  { include_examples 'player' }
      context_as_player2  { include_examples 'player' }
    end

    context 'when 同じ問題に複数解答ある' do
      context 'when 本戦(Config.realtime_grading == true)' do
        context 'when 遅延中の解答無し' do
          shared_examples 'all' do
            before(:each) do
              answer1.grade(percent: 100) # 最高得点(有効)
              answer2.grade(percent: 10)  # 採点済み最終解答(無効)
              # answer3                   # 最終解答(無効)
            end

            let(:problem) { create(:problem) }
            let(:created_at) { Time.current - Config.grading_delay_sec }
            let!(:answer1) { create(:answer, problem: problem, team: player1, created_at: created_at - 3.seconds) }
            let!(:answer2) { create(:answer, problem: problem, team: player1, created_at: created_at - 2.seconds) }
            let!(:answer3) { create(:answer, problem: problem, team: player1, created_at: created_at - 1.second) }

            it '最高得点を採用' do
              expect(Answer.count).to eq(3)
              expect(Score.count).to eq(2)
              expect(answer1.created_at).to be < answer2.created_at
              expect(answer2.created_at).to be < answer3.created_at

              post_query
              expect(response_json).not_to have_gql_errors
              expect(response_gql.size).to eq(2)
              expect(response_gql).to match_array([
                                                    include({ 'teamId' => player1.id, 'rank' => 1, 'score' => answer1.score.point }),
                                                    include({ 'teamId' => player2.id, 'rank' => 2, 'score' => 0 })
                                                  ])
            end
          end

          context_as_staff    { include_examples 'all' }
          context_as_audience { include_examples 'all' }
          context_as_player1  { include_examples 'all' }
        end

        context 'when 遅延中の解答有り' do
          before(:each) do
            answer1.grade(percent: 10)  # 遅延後(有効)
            answer2.grade(percent: 5)   # 遅延後の中では最終解答(無効)
            answer3.grade(percent: 100) # 最高得点だが遅延中(無効)
          end

          let(:problem) { create(:problem) }
          let!(:answer1) { create(:answer, problem: problem, team: player1, created_at: Time.current - Config.grading_delay_sec - 2.seconds) }
          let!(:answer2) { create(:answer, problem: problem, team: player1, created_at: Time.current - Config.grading_delay_sec - 1.second) }
          let!(:answer3) { create(:answer, problem: problem, team: player1, created_at: Time.current) }

          shared_examples 'not player' do
            it '最高得点を採用' do
              expect(Answer.count).to eq(3)
              expect(Score.count).to eq(3)
              expect(answer1.created_at).to be < answer2.created_at
              expect(answer2.created_at).to be < answer3.created_at

              post_query
              expect(response_json).not_to have_gql_errors
              expect(response_gql.size).to eq(2)
              expect(response_gql).to match_array([
                                                    include({ 'teamId' => player1.id, 'rank' => 1, 'score' => answer3.score.point }),
                                                    include({ 'teamId' => player2.id, 'rank' => 2, 'score' => 0 })
                                                  ])
            end
          end

          shared_examples 'player' do
            it '遅延中じゃない最高得点を採用' do
              expect(Answer.count).to eq(3)
              expect(Score.count).to eq(3)
              expect(answer1.created_at).to be < answer2.created_at
              expect(answer2.created_at).to be < answer3.created_at

              post_query
              expect(response_json).not_to have_gql_errors
              expect(response_gql.size).to eq(2)
              expect(response_gql).to match_array([
                                                    include({ 'teamId' => player1.id, 'rank' => 1, 'score' => answer1.score.point }),
                                                    include({ 'teamId' => player2.id, 'rank' => 2, 'score' => 0 })
                                                  ])
            end
          end

          context_as_staff    { include_examples 'not player' }
          context_as_audience { include_examples 'not player' }
          context_as_player1  { include_examples 'player' }
        end
      end

      context 'when 予選(Config.realtime_grading == false)' do
        before(:each) do
          # 予選用の設定(差分)
          Config.realtime_grading = false
          Config.hide_all_score = true
        end

        shared_examples 'all' do
          before(:each) do
            answer1.grade(percent: 100) # 最高得点だが最終解答ではない
            answer2.grade(percent: 10)  # 有効解答
            # answer3                   # 最終解答だが未採点
          end

          let(:problem) { create(:problem) }
          let!(:answer1) { create(:answer, problem: problem, team: player1, created_at: Time.current + 1.second) }
          let!(:answer2) { create(:answer, problem: problem, team: player1, created_at: Time.current + 2.seconds) }
          let!(:answer3) { create(:answer, problem: problem, team: player1, created_at: Time.current + 3.seconds) }

          it '採点済み最終解答のみ採用' do
            expect(Answer.count).to eq(3)
            expect(Score.count).to eq(2)
            expect(answer1.created_at).to be < answer2.created_at
            expect(answer2.created_at).to be < answer3.created_at

            post_query
            expect(response_json).not_to have_gql_errors
            expect(response_gql.size).to eq(2)
            expect(response_gql).to match_array([
                                                  include({ 'teamId' => player1.id, 'rank' => 1, 'score' => answer2.score.point }),
                                                  include({ 'teamId' => player2.id, 'rank' => 2, 'score' => 0 })
                                                ])
          end
        end

        context_as_staff    { include_examples 'all' }
        context_as_audience { include_examples 'all' }
      end
    end

    context 'when 複数の問題に解答ある' do
      let(:problem1) { create(:problem) }
      let(:problem2) { create(:problem) }
      let(:created_at) { Time.current - Config.grading_delay_sec }
      let(:answer11) { create(:answer, problem: problem1, team: player1, created_at: created_at) }
      let(:answer12) { create(:answer, problem: problem2, team: player1, created_at: created_at) }
      let(:answer21) { create(:answer, problem: problem1, team: player2, created_at: created_at) }

      before(:each) do
        answer11.grade(percent: 100)
        answer12.grade(percent: 10)
        answer21.grade(percent: 100)
      end

      shared_examples 'all' do
        it '集計される' do
          expect(player1.answers.count).to eq(2)
          expect(player2.answers.count).to eq(1)
          expect(problem1.answers.count).to eq(2)
          expect(problem2.answers.count).to eq(1)
          expect(Score.count).to eq(3)

          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(2)
          expect(response_gql).to match_array([
                                                include({ 'teamId' => player1.id, 'rank' => 1, 'score' => answer11.score.point + answer12.score.point }),
                                                include({ 'teamId' => player2.id, 'rank' => 2, 'score' => answer21.score.point })
                                              ])
        end
      end

      context_as_staff    { include_examples 'all' }
      context_as_audience { include_examples 'all' }
      context_as_player1  { include_examples 'all' }
      context_as_player2  { include_examples 'all' }
    end
  end

  describe 'ペナルティの仕様(Config.penalty_weight)' do
    before(:each) do
      problem1 = create(:problem, resettable: true)
      problem2 = create(:problem, resettable: true)
      create(:penalty, problem: problem1, team: player1)
      create(:penalty, problem: problem1, team: player2)
      create(:penalty, problem: problem2, team: player2)
    end

    context 'when penalty_weight is -10' do
      before(:each) do
        Config.penalty_weight = -10
      end

      shared_examples 'all' do
        it '各チームの合計ペナルティ数分得点が下がる' do
          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(2)
          expect(response_gql).to match_array([
                                                include({ 'teamId' => player1.id, 'rank' => 1, 'score' => -10 }),
                                                include({ 'teamId' => player2.id, 'rank' => 2, 'score' => -20 })
                                              ])
        end
      end

      context_as_staff    { include_examples 'all' }
      context_as_audience { include_examples 'all' }
      context_as_player1  { include_examples 'all' }
      context_as_player2  { include_examples 'all' }
    end

    context 'when penalty_weight is 0' do
      before(:each) do
        Config.penalty_weight = 0
      end

      shared_examples 'all' do
        it 'ペナルティがあっても得点が下がらない' do
          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(2)
          expect(response_gql).to match_array([
                                                include({ 'teamId' => player1.id, 'rank' => 1, 'score' => 0 }),
                                                include({ 'teamId' => player2.id, 'rank' => 1, 'score' => 0 })
                                              ])
        end
      end

      context_as_staff    { include_examples 'all' }
      context_as_audience { include_examples 'all' }
      context_as_player1  { include_examples 'all' }
      context_as_player2  { include_examples 'all' }
    end
  end

  describe '表示の仕様(Config.scoreboard)' do
    context 'when 予選' do
      before(:each) do
        # 予選用の設定(差分)
        Config.realtime_grading = false
        Config.hide_all_score = true

        create(:answer, problem: create(:problem), team: player1)
          .grade(percent: 100)
      end

      shared_examples 'not player' do
        it 'スコアボードが見える' do
          expect(Team.player_without_team99.count).to eq(2)

          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(2)
        end
      end

      shared_examples 'player' do
        it 'スコアボードは見えない' do
          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(0)
        end
      end

      context_as_staff    { include_examples 'not player' }
      context_as_audience { include_examples 'not player' }
      context_as_player1  { include_examples 'player' }
    end

    describe 'Config.scoreboard.hide_at' do
      before(:each) do
        Config.scoreboard_hide_at = Time.current - 1.second
      end

      shared_examples 'not player' do
        it '全て見える' do
          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(2)
        end
      end

      shared_examples 'player' do
        it '自分のみ' do
          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(1)
        end
      end

      context_as_staff    { include_examples 'not player' }
      context_as_audience { include_examples 'not player' }
      context_as_player1  { include_examples 'player' }
      context_as_player2  { include_examples 'player' }
    end

    describe 'Config.scoreboard_top' do
      before(:each) do
        Config.scoreboard_top = 3

        problem = create(:problem)

        create(:answer, :created_at_after_delay, problem: problem, team: player1)
          .grade(percent: 50)
        create(:answer, :created_at_after_delay, problem: problem, team: player3)
          .grade(percent: 100)
        create(:answer, :created_at_after_delay, problem: problem, team: player4)
          .grade(percent: 70)
      end

      # チーム作成は重い
      let!(:player3) { create(:team, :player, name: 'player3', beginner: false) }
      let!(:player4) { create(:team, :player, name: 'player4', beginner: false) }
      let!(:player5) { create(:team, :player, name: 'player5', beginner: false) } # rubocop:disable RSpec/LetSetup

      shared_examples 'not player' do
        it '全て見える' do
          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(5)
        end
      end

      shared_examples 'player1' do
        it '自分と上位Nチーム' do
          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(3)
        end
      end

      shared_examples 'player2' do
        it '上位Nチーム(自分含む)' do
          post_query
          expect(response_json).not_to have_gql_errors
          expect(response_gql.size).to eq(4)
        end
      end

      context_as_staff    { include_examples 'not player' }
      context_as_audience { include_examples 'not player' }
      context_as_player1  { include_examples 'player1' }
      context_as_player2  { include_examples 'player2' }
    end

    describe 'Config.scoreboard_display' do
      describe 'top' do # rubocop:disable RSpec/EmptyExampleGroup
        # TODO: 未作成
        before(:each) do
          # もう一方の影響を無くす
          Config.scoreboard_display_above_team  = false
          Config.scoreboard_display_above_score = false
        end
      end

      describe 'above' do # rubocop:disable RSpec/EmptyExampleGroup
        # TODO: 未作成
        before(:each) do
          # もう一方の影響を無くす
          Config.scoreboard_display_top_team    = false
          Config.scoreboard_display_top_score   = false
        end
      end
    end
  end
end
