# frozen_string_literal: true

module Mutations
  class AddIssueComment < GraphQL::Schema::RelayClassicMutation
    field :issue, Types::IssueType, null: true
    field :issue_comment, Types::IssueCommentType, null: true
    field :errors, [String], null: false

    argument :issue_id, ID, required: true
    argument :text, String, required: true

    def resolve(issue_id:, text:)
      issue = Issue.find_by!(id: issue_id)
      Acl.permit!(mutation: self, args: { issue: issue })

      issue.transition_by_comment(team: Context.current_team!)
      issue_comment = IssueComment.new(text: text, from_staff: Context.current_team!.staff?)

      # issueも同時にsaveされる
      if issue_comment.update(issue: issue)
        { issue: issue.readable, issue_comment: issue_comment.readable, errors: [] }
      else
        { errors: issue.errors.full_messages + issue_comment.errors.full_messages }
      end
    end
  end
end
