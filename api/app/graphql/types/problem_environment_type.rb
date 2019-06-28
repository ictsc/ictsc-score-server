# frozen_string_literal: true

module Types
  class ProblemEnvironmentType < Types::BaseObject
    field :id,         ID,                 null: false
    field :team_id,    ID,                 null: false
    field :team,       Types::TeamType,    null: false
    field :problem_id, ID,                 null: false
    field :problem,    Types::ProblemType, null: false
    field :status,     String,             null: false
    field :host,       String,             null: false
    field :user,       String,             null: false
    field :password,   String,             null: false
    field :created_at, Types::DateTime,    null: false
    field :updated_at, Types::DateTime,    null: false

    def team
      RecordLoader.for(Team).load(self.object.team_id)
    end

    def problem
      RecordLoader.for(Problem).load(self.object.problem_id)
    end
  end
end
