# frozen_string_literal: true

# 仕様概要
#   staffとaudienceは常に全てのレコードの全ての情報が見れる
#   player
#     team.beginnerの値が同じレコードのみ見える
#     scoreboard_hide_atを超えると自身のscoreのみ見えるようになる(rankは見えなくなる)
#     その他の表示は設定依存

class Scoreboard
  class << self
    def readables(team:) # rubocop:disable Metrics/CyclomaticComplexity
      return [] if !team.staff? && !Config.competition?
      return [] if team.player? && Config.hide_all_score

      answers = ScoreAggregator.effective_graded_answers(team: team)
      teams = team.team99? ? Team.player : Team.player_without_team99
      records = ScoreAggregator.aggregate(teams: teams, answers: answers, penalties: Penalty.all)

      return records if team.staff? || team.audience?

      filter_records_for_player(team: team, records: records)
    end

    private

    def filter_records_for_player(team:, records:)
      team_record = records.find {|record| team.id == record[:team_id] }

      # team.beginnerの値が同じレコードのみ見える
      records = records.select {|record| team.beginner == record[:team].beginner }

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
end
