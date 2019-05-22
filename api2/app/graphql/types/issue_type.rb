# frozen_string_literal: true

module Types
  class IssueType < Types::BaseObject
    field :id,         ID,                        null: false
    field :title,      String,                    null: false
    field :status,     Types::Enums::IssueStatus, null: false
    field :problem,    Types::ProblemType,        null: false
    field :team,       Types::TeamType,           null: false
    field :comments,   [Types::IssueCommentType], null: false
    field :created_at, Types::DateTime,           null: false

    def status
      # staff以外ならin_progressをunsolvedとして返す
      # TODO: commentが付いているなら, in_progressと表示したい
      #       複雑なので、いそin_progressフィールを分けて、staffはin_progressがtrueか見て、playerはcommentがあるかを見たほうが良さそう?
      return 'unsolved' if !Context.current_team!.staff && self.object.in_progress?

      self.object.status
    end

    def problem
      RecordLoader.for(Problem).load(self.object.problem_id)
    end

    def team
      RecordLoader.for(Team).load(self.object.team_id)
    end

    def comments
      AssociationLoader.for(Issue, :comments).load(self.object)
    end
  end
end
