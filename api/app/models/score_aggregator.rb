# frozen_string_literal: true

class ScoreAggregator
  class << self
    # 指定teamのスコアボード生成に使える解答のみ返す
    def effective_answers(team:)
      rel = Answer.includes(:score).where(score: Score.where.not(point: nil))
      (team.player? && Config.realtime_grading) ? rel.delay_filter : rel
    end

    # Answerリストからチーム毎の最も有効な解答一覧を作る
    # answers: [Answer]
    # return: [{ team_id: [Answer] }]
    def aggregate_answers(answers:)
      # &:team にしないこと(実行時間5倍)
      teams_answers = answers.group_by(&:team_id)
      teams_answers.transform_values! {|team_answers| select_most_effective_answers(team_answers: team_answers) }
      # 解答が無いチーム対策
      teams_answers.default = [].freeze
      teams_answers
    end

    # チーム毎のペナルティを計算する
    def aggregate_penalties(penalties:)
      # ほぼSQL側で集計
      penalties
        .group(:team_id)
        .count
        .transform_values {|total_count| total_count * Config.penalty_weight }
        .tap {|hash| hash.default = 0 } # ペナルティが無いチーム対策
    end

    # チーム毎に集計する
    # { :team_id=>"bc1a8747-ed32-4f62-8811-2090a589d063", :score=>17775, :rank=>1 } のソート済み配列
    # beginnerかどうかで独立してrankが付く
    def aggregate(teams:, answers:, penalties:)
      teams_answers = aggregate_answers(answers: answers)
      teams_penalty_scores = aggregate_penalties(penalties: penalties)

      # 解答の無いチームも集計対象とする
      #   1. チーム毎に得点集計
      #   2. beginnerとそうでないものを分離
      #   3. 分離したものをそれぞれランク付け&結合
      teams
        .map {|team| build_record(team: team, team_answers: teams_answers[team.id], penalty_score: teams_penalty_scores[team.id]) }
        .group_by {|record| record[:team].beginner }
        .sum {|_key, records| assign_rank(records: records) }
    end

    private

    def build_record(team:, team_answers:, penalty_score:)
      {
        team_id: team.id,
        score: penalty_score + team_answers.sum {|answer| answer.score.point },
        rank: 0, # dummy

        perfect_count: team_answers.count {|answer| answer.score.percent >= 100 },
        team: team, # ランク付与, 得点表出力, フィルタ, etc...
        answers: team_answers # 得点表出力
      }
    end

    # 各問題の解答から最優先のもののみ取り出す
    def select_most_effective_answers(team_answers:)
      team_answers.each_with_object({}) {|answer, currents|
        if currents[answer.problem_id].nil? || higher_priority_answer?(current: currents[answer.problem_id], new: answer)
          currents[answer.problem_id] = answer
        end
      }
        .values
    end

    def higher_priority_answer?(current:, new:)
      if Config.realtime_grading
        # 最高得点が優先
        current.score.point < new.score.point
      else
        # 最終解答が優先
        current.created_at < new.created_at
      end
    end

    def assign_rank(records:)
      return [] if records.empty?

      records.sort_by! {|e| [-e[:score], -e[:perfect_count]] }
      records.first[:rank] = 1

      # 同点時の順位は 1 2 2 4
      records.each_cons(2).with_index(2) do |(previous_data, data), index|
        data[:rank] = (previous_data[:score] == data[:score] && previous_data[:perfect_count] == data[:perfect_count]) ? previous_data[:rank] : index
      end

      records
    end
  end
end
