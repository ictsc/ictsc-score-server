# frozen_string_literal: true

module Types
  class ScoreboardType < Types::BaseObject
    # 設定によってどのカラムもnullになり得る
    field :rank,    Integer,         null: true
    field :score,   Integer,         null: true
    field :team_id, ID,              null: true
    field :team,    Types::TeamType, null: true

    def team
      RecordLoader.for(self.context, Team).load(self.object[:team_id]) if self.object[:team_id].present?
    end
  end
end
