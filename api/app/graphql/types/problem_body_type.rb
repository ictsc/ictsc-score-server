# frozen_string_literal: true

module Types
  class ProblemBodyType < Types::BaseObject
    field :id,               ID,                            null: false
    field :mode,             Types::Enums::ProblemBodyMode, null: false
    field :title,            String,                        null: false
    field :text,             String,                        null: false
    field :perfect_point,    Integer,                       null: false
    field :solved_criterion, Integer,                       null: false
    field :problem_id,       ID,                            null: false
    field :candidates,       [[String]],                    null: true
    field :corrects,         [[String]],                    null: true
    field :created_at,       Types::DateTime,               null: false
    field :updated_at,       Types::DateTime,               null: false
  end
end
