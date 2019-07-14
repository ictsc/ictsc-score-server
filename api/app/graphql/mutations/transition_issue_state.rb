# frozen_string_literal: true

module Mutations
  class TransitionIssueState < GraphQL::Schema::RelayClassicMutation
    field :issue, Types::IssueType, null: true
    field :errors, [String], null: false

    argument :issue_id, ID, required: true

    def resolve(issue_id:)
      issue = Issue.find_by!(id: issue_id)
      Acl.permit!(mutation: self, args: { issue: issue })

      issue.transition_by_click(team: Context.current_team!)

      if issue.save
        { issue: issue.readable, errors: [] }
      else
        { errors: issue.errors.full_messages }
      end
    end
  end
end
