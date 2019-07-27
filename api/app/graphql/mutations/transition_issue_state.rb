# frozen_string_literal: true

module Mutations
  class TransitionIssueState < BaseMutation
    field :issue, Types::IssueType, null: true

    argument :issue_id, ID, required: true

    def resolve(issue_id:)
      issue = Issue.find_by(id: issue_id)
      raise RecordNotExists.new(Issue, id: issue_id) if issue.nil?

      Acl.permit!(mutation: self, args: { issue: issue })

      issue.transition_by_click(team: Context.current_team!)

      if issue.save
        { issue: issue.readable, errors: [] }
      else
        add_errors(issue)
      end
    end
  end
end
