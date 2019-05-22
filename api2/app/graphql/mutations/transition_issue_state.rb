# frozen_string_literal: true

module Mutations
  class TransitionIssueState < GraphQL::Schema::RelayClassicMutation
    # TODO: issueのstatusの仕様が未決定なため、後回し
    field :issue, Types::IssueType, null: true
    field :errors, [String], null: false

    # argument :issue_id, ID, required: true
    #
    # def resolve(issue_id:)
    #   issue = Issue.find!(issue_id)
    #   Acl.permit!(mutation: self, args: { issue: issue })
    #
    #   if issue.destroy
    #     { issue: issue.readable, errors: [] }
    #   else
    #     { errors: issue.errors.full_messages }
    #   end
    # end
  end
end
