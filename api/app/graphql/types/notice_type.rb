# frozen_string_literal: true

module Types
  class NoticeType < Types::BaseObject
    field :id,             ID,              null: false
    field :title,          String,          null: false
    field :text,           String,          null: false
    field :pinned,         Boolean,         null: false
    field :target_team_id, ID,              null: true
    field :target_team,    Types::TeamType, null: true
    field :created_at,     Types::DateTime, null: false

    belongs_to :target_team
  end
end
