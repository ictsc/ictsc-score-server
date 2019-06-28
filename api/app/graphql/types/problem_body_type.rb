# frozen_string_literal: true

module Types
  class ProblemBodyType < Types::BaseObject
    field :id,            ID,                            null: false
    field :mode,          Types::Enums::ProblemBodyMode, null: true
    field :title,         String,                        null: true
    field :text,          String,                        null: true
    field :perfect_point, Integer,                       null: true
    field :problem_id,    ID,                            null: false
    field :candidates,    [[String]],                    null: true
    field :corrects,      [[String]],                    null: true
    field :created_at,    Types::DateTime,               null: false
    field :updated_at,    Types::DateTime,               null: false
  end
end
