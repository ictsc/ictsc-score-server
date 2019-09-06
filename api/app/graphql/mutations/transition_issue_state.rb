# frozen_string_literal: true

module Mutations
  class TransitionIssueState < BaseMutation
    field :issue, Types::IssueType, null: true

    argument :issue_id, ID, required: true
    # 同時リクエストで意図しない遷移を防ぐため
    argument :current_status, Types::Enums::IssueStatus, required: true

    def resolve(issue_id:, current_status:) # rubocop:disable Lint/UnusedMethodArgument
      issue = Issue.find_by(id: issue_id)
      raise RecordNotExists.new(Issue, id: issue_id) if issue.nil?

      # TODO: 楽観ロックか悲観ロックしたほうがいい
      # TODO: ユーザーに対応中を見せなくする変更の影響で一時的に無効化
      # raise IssueCurrentStatusMismatched.new(expected: current_status, got: issue.status) if current_status != issue.status

      Acl.permit!(mutation: self, args: { issue: issue })

      issue.transition_by_click(team: self.context.current_team!)

      if issue.save
        { issue: issue.readable(team: self.context.current_team!) }
      else
        add_errors(issue)
      end
    end
  end
end
