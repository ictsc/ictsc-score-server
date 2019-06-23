# frozen_string_literal: true

module Types
  class NoticeType < Types::BaseObject
    field :id,          ID,              null: false
    field :title,       String,          null: false
    field :text,        String,          null: false
    field :target_team, Types::TeamType, null: true
    field :created_at,  Types::DateTime, null: false

    def target_team
      RecordLoader.for(Team).load(self.object.target_team_id)
    end
  end
end
