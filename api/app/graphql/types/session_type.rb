# frozen_string_literal: true

module Types
  class SessionType < Types::BaseObject
    field :id,      ID, null: false
    # セッションの中身が空な場合がある
    field :team_id, ID, null: true
    field :team,    Types::TeamType, null: true

    def team
      RecordLoader.for(self.context, Team).load(self.object.team_id)
    end
  end
end
