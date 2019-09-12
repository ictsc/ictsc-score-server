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
    field :created_at, Types::DateTime,    null: false
    # Scoreに透過的にアクセスする
    field :point,      Integer,            null: true
    field :percent,    Integer,            null: true
    field :solved,     Boolean,            null: true

    belongs_to :problem
    belongs_to :team

    has_one :point, :score do |score|
      next nil if score.nil?

      score.point
    end

    has_one :percent, :score do |score|
      next nil if score.nil?

      score.percent
    end

    has_one :solved, :score do |score|
      next nil if score.nil?

      score.solved
    end
  end
end
