# frozen_string_literal: true

module Types
  class ProblemSupplementType < Types::BaseObject
    field :id,         ID,              null: false
    field :text,       String,          null: false
    field :problem_id, ID,              null: false
    field :created_at, Types::DateTime, null: false
  end
end
