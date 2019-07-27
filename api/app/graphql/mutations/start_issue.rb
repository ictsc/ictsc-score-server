# frozen_string_literal: true

module Mutations
  class StartIssue < BaseMutation
    field :issue, Types::IssueType, null: true

    argument :problem_id, ID, required: true

    def resolve(problem_id:)
      problem = Problem.find_by(id: problem_id)
      raise RecordNotExists.new(Problem, id: problem_id) if problem.nil?

      args = { problem: problem }
      Acl.permit!(mutation: self, args: args)

      issue = Issue.new

      if issue.update(args.merge(title: title, status: 'unsolved', team: Context.current_team!))
        { issue: issue.readable }
      else
        add_errors(issue)
      end
    end
  end
end
