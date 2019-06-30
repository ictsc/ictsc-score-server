# frozen_string_literal: true

module Mutations
  class AddIssue < GraphQL::Schema::RelayClassicMutation
    field :issue, Types::IssueType, null: true
    field :errors, [String], null: false

    argument :problem_id, ID, required: true
    argument :title, String, required: true

    def resolve(problem_id:, title:)
      args = { problem: Problem.find_by!(id: problem_id) }
      Acl.permit!(mutation: self, args: args)

      issue = Issue.new

      if issue.update(args.merge(title: title, status: 'unsolved', team: Context.current_team!))
        { issue: issue.readable, errors: [] }
      else
        { errors: issue.errors.full_messages }
      end
    end
  end
end
