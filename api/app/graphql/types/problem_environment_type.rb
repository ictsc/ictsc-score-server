# frozen_string_literal: true

module Types
  class ProblemEnvironmentType < Types::BaseObject
    field :id,         ID,                 null: false
    field :team_id,    ID,                 null: true
    field :team,       Types::TeamType,    null: true
    field :problem_id, ID,                 null: false
    field :problem,    Types::ProblemType, null: false
    field :name,       String,             null: false

    field :status,     String,             null: false
    field :host,       String,             null: false
    field :user,       String,             null: false
    field :password,   String,             null: false
    field :note,       String,             null: true
    field :created_at, Types::DateTime,    null: false
    field :updated_at, Types::DateTime,    null: false

    belongs_to :team
    belongs_to :problem
  end
end
