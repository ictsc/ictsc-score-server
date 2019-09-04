# frozen_string_literal: true

module Types
  class IssueType < Types::BaseObject
    field :id,         ID,                        null: false
    field :status,     Types::Enums::IssueStatus, null: false
    field :problem_id, ID,                        null: false
    field :problem,    Types::ProblemType,        null: false
    field :team_id,    ID,                        null: false
    field :team,       Types::TeamType,           null: false
    field :comments,   [Types::IssueCommentType], null: false
    # status更新時間
    field :updated_at, Types::DateTime,           null: false

    def status
      # staff以外には対応中を見せない
      return 'unsolved' if !Context.current_team!.staff? && self.object.in_progress?

      self.object.status
    end

    def problem
      RecordLoader.for(Problem).load(self.object.problem_id)
    end

    def team
      RecordLoader.for(Team).load(self.object.team_id)
    end

    has_many :comments
  end
end
