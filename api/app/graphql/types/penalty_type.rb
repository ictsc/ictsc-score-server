# frozen_string_literal: true

module Types
  class PenaltyType < Types::BaseObject
    field :id,         ID,                 null: false
    field :count,      Integer,            null: false
    field :problem_id, ID,                 null: false
    field :problem,    Types::ProblemType, null: false
    field :team_id,    ID,                 null: false
    field :team,       Types::TeamType,    null: false
    field :created_at, Types::DateTime,    null: false
    field :updated_at, Types::DateTime,    null: false

    belongs_to :problem
    belongs_to :team
  end
end
