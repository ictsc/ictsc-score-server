# frozen_string_literal: true

module Types
  class AnswerType < Types::BaseObject
    field :id,         ID, null: false
    field :bodies,     [[String]],         null: false
    field :confirming, Boolean,            null: true
    field :problem,    Types::ProblemType, null: false
    field :team,       Types::TeamType,    null: false
    field :score,      Types::ScoreType,   null: true
    field :created_at, Types::DateTime, null: false

    def problem
      RecordLoader.for(Problem).load(self.object.problem_id)
    end

    def team
      RecordLoader.for(Team).load(self.object.team_id)
    end

    def score
      RecordLoader.for(Score).load(self.object.score_id)
    end
  end
end
