# frozen_string_literal: true

module Types
  class AnswerType < Types::BaseObject
    field :id,         ID,                 null: false
    field :bodies,     [[String]],         null: false
    field :confirming, Boolean,            null: true
    field :problem_id, ID,                 null: false
    field :problem,    Types::ProblemType, null: false
    field :team_id,    ID,                 null: false
    field :team,       Types::TeamType,    null: false
    field :score,      Types::ScoreType,   null: true
    field :created_at, Types::DateTime,    null: false

    belongs_to :problem
    belongs_to :team
    has_one :score
  end
end
