# frozen_string_literal: true

module Types
  class NoticeType < Types::BaseObject
    field :id,             ID,              null: false
    field :title,          String,          null: false
    field :text,           String,          null: false
    field :pinned,         Boolean,         null: false
    field :team_id,        ID,              null: true
    field :team,           Types::TeamType, null: true
    field :created_at,     Types::DateTime, null: false

    belongs_to :team
  end
end
