# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :me, Types::TeamType, null: true
    field :contest_info, Types::ContestInfo, null: false
    field :categories, [Types::CategoryType], null: false
    field :problem, Types::ProblemType, null: true do
      argument :id, ID, required: true
    end
    field :problems, [Types::ProblemType], null: false
    field :teams, [Types::TeamType], null: false
    field :notices, [Types::NoticeType], null: false

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
      Problem.readables(team: self.context.current_team!).find_by(id: id)
    end

    def problems
      Problem.readables(team: self.context.current_team!)
    end

    def teams
      Team.readables(team: self.context.current_team!)
    end

    def notices
      Notice.readables(team: self.context.current_team!)
    end

    # field :problem, Types::ProblemType, null: false do
    #   argument :id, ID, required: true
    # end

    # def problem(id:)
    #   RecordLoader.for(Problem).load(id)
    # end
  end
end
