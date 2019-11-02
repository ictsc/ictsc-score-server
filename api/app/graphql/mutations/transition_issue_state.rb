# frozen_string_literal: true

module Mutations
  class TransitionIssueState < BaseMutation
    field :issue, Types::IssueType, null: true

    argument :issue_id,       ID,                        required: true
    # 同時リクエストで意図しない遷移を防ぐため
    argument :current_status, Types::Enums::IssueStatus, required: true

    def resolve(issue_id:, current_status:)
      issue = Issue.find_by(id: issue_id)
      raise RecordNotExists.new(Issue, id: issue_id) if issue.nil?

      # TODO: 楽観ロックか悲観ロックしたほうがいい
      response_status = issue.response_status(team: self.current_team!)
      raise IssueCurrentStatusMismatched.new(expected: current_status, got: response_status) if current_status != response_status

      Acl.permit!(mutation: self, args: { issue: issue })

      issue.transition_by_click(team: self.current_team!)

      if issue.save
        { issue: issue.readable(team: self.current_team!) }
      else
        add_errors(issue)
      end
    end
  end
end
