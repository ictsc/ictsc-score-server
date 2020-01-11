# frozen_string_literal: true

# 仕様概要
#   staffとaudienceは常に全てのレコードの全ての情報が見れる
#   player
#     team.beginnerの値が同じレコードのみ見える
#     scoreboard_hide_atを超えると自身のscoreのみ見えるようになる(rankは見えなくなる)
#     その他の表示は設定依存

class Scoreboard
  class << self
    def readables(team:)
      return [] if team.player? && (Config.hide_all_score || !Config.competition?)

      records = aggregate(teams: Team.player, answers: effective_answers(team: team))

      return records if team.staff? || team.audience?

      filter_records_for_player(team: team, records: records)
    end

    def filter_records_for_player(team:, records:)
      team_record = records.find {|record| team.id == record[:team_id] }

      # team.beginnerの値が同じレコードのみ見える
      records = records.select {|record| team.beginner == record[:_beginner] }

      # 自身のレコードのみ見せる
      records = [team_record] if Config.scoreboard_hide_at <= DateTime.current

      records.map {|record|
        display_mode = select_display_mode(team_record: team_record, record: record, records: records)
        next unless display_mode

        filter_record(record: record, display_mode: display_mode)
      }
        .compact
    end

    def select_display_mode(team_record:, record:, records:)
      if record[:team_id] == team_record[:team_id]
        :all
      elsif record[:rank] <= Config.scoreboard_top
        :top
      elsif team_record[:rank] == (record[:rank] + count_same_rank(rank: record[:rank], records: records))
        # 1ランク上のチーム全て
        # e.g. 1 2 2 4 のとき 4 == 2 + count_same_rank(2)
        :above
      else
        # 表示しない
        nil
      end
    end

    def count_same_rank(rank:, records:)
      records.count {|record| rank == record[:rank] }
    end

    def filter_record(record:, display_mode:)
      keys = []
      keys << :rank if DateTime.current < Config.scoreboard_hide_at
      keys << :team_id if Config.scoreboard_display[display_mode][:team]
      keys << :score if Config.scoreboard_display[display_mode][:score]

      record.slice(*keys)
    end
  end

  # 集計用関数群
  class << self
    private

    # 指定teamのスコアボード生成に使える解答のみ返す
    def effective_answers(team:)
      rel = Answer.includes(:score).where(score: Score.where.not(point: nil))
      (team.player? && Config.realtime_grading) ? rel.delay_filter : rel
    end

    # チーム毎に集計する
    # {:team_id=>"bc1a8747-ed32-4f62-8811-2090a589d063", :score=>17775, :rank=>1 } のソート済み配列
    # beginnerかどうかで独立してrankが付く
    def aggregate(teams:, answers:)
      # &:team にしないこと(実行時間5倍)
      teams_answers = answers.group_by(&:team_id)

      # 解答の無いチームも集計対象とする
      #   1. 得点集計
      #   2. beginnerとそうでないものを分離
      #   3. 分離したものをそれぞれランク付け&結合
      teams
        .map {|team| build_record(team: team, team_answers: teams_answers[team.id]) }
        .group_by {|record| record[:_beginner] }
        .sum {|_key, records| assign_rank(records: records) }
    end

    def build_record(team:, team_answers:)
      {
        team_id: team.id,
        score: aggregate_score(team_answers: team_answers),
        rank: 0, # dummy
        _beginner: team.beginner # ランク付与用
      }
    end

    def aggregate_score(team_answers:)
      # 解答が1つも無い
      return 0 if team_answers.blank?

      select_most_effective_answers(team_answers: team_answers)
        .sum {|_answer_id, answer| answer.score.point }
    end

    # 各問題の解答から最優先のもののみ取り出す
    def select_most_effective_answers(team_answers:)
      team_answers.each_with_object({}) do |answer, currents|
        if currents[answer.id].nil? || higher_priority_answer?(current: currents[answer.id], new: answer)
          currents[answer.id] = answer
        end
      end
    end

    def higher_priority_answer?(current:, new:)
      if Config.realtime_grading
        # 最高得点が優先
        current[answer.id].score.point < new.score.point
      else
        # 最終解答が優先
        current[answer.id].created_at < new.created_at
      end
    end

    def assign_rank(records:)
      return [] if records.empty?

      records.sort_by! {|e| -e[:score] }
      records.first[:rank] = 1

      # 同点時の順位は 1 2 2 4
      records.each_cons(2).with_index(2) do |(previous_data, data), index|
        data[:rank] = (previous_data[:score] == data[:score]) ? previous_data[:rank] : index
      end

      records
    end
  end
end
