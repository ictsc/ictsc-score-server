# frozen_string_literal: true

module Mutations
  class AddIssueComment < GraphQL::Schema::RelayClassicMutation
    field :issue_comment, Types::IssueCommentType, null: true
    field :errors, [String], null: false

    argument :issue_id, ID, required: true
    argument :text, String, required: true

    def resolve(issue_id:, text:)
      args = { issue: Issue.find!(issue_id) }
      Acl.permit!(mutation: self, args: args)

      issue_comment = IssueComment.new

      if issue_comment.update(args.merge(text: text, from_staff: Context.current_team!.staff?))
        { issue_comment: issue_comment.readable, errors: [] }
      else
        { errors: issue_comment.errors.full_messages }
      end
    end
  end
end
