# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :me, Types::TeamType, null: true
    field :contest_info, Types::ContestInfo, null: false
    field :categories, [Types::CategoryType], null: false
    field :problem, Types::ProblemType, null: true do
      argument :id, ID, required: true
    end
    field :problems, [Types::ProblemType], null: false
    field :problem_environments, [Types::ProblemEnvironmentType], null: false
    field :team, Types::TeamType, null: true do
      argument :id, ID, required: true
    end
    field :teams, [Types::TeamType], null: false
    field :notices, [Types::NoticeType], null: false
    field :sessions, [Types::SessionType], null: false

    def me
      self.context.current_team!.readable(team: self.context.current_team!)
    end

    def contest_info
      # 全ユーザーが見える情報のみ返す
      Config
    end

    def categories
      Category.readables(team: self.context.current_team!)
    end

    def problem(id:)
      Problem.find_by(id: id).readable(team: self.context.current_team!)
    end

    def problems
      Problem.readables(team: self.context.current_team!)
    end

    def problem_environments
      ProblemEnvironment.readables(team: self.context.current_team!)
    end

    def team(id:)
      Team.find_by(id: id).readable(team: self.context.current_team!)
    end

    def teams
      Team.readables(team: self.context.current_team!)
    end

    def notices
      Notice.readables(team: self.context.current_team!)
    end

    def sessions
      Session.readable_records(team: self.context.current_team!)
    end
  end
end
