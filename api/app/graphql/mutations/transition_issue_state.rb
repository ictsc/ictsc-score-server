# frozen_string_literal: true

module Mutations
  class TransitionIssueState < BaseMutation
    field :issue, Types::IssueType, null: true

    argument :issue_id, ID, required: true
    # 同時リクエストで意図しない遷移を防ぐため
    argument :current_status, Types::Enums::IssueStatus, required: true

    def resolve(issue_id:, current_status:)
      issue = Issue.find_by(id: issue_id)
      raise RecordNotExists.new(Issue, id: issue_id) if issue.nil?
      # TODO: 楽観ロックか悲観ロックしたほうがいい
      raise IssueCurrentStatusMismatched.new(expected: current_status, got: issue.status) if current_status != issue.status

      Acl.permit!(mutation: self, args: { issue: issue })

      issue.transition_by_click(team: Context.current_team!)

      if issue.save
        { issue: issue.readable }
      else
        add_errors(issue)
      end
    end
  end
end
