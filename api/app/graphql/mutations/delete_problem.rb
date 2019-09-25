# frozen_string_literal: true

module Mutations
  class DeleteProblem < BaseMutation
    field :problem,      Types::ProblemType,     null: false
    field :problem_body, Types::ProblemBodyType, null: false

    argument :code, String, required: true

    def resolve(code:)
      # 削除時は事前にフィルタする必要がある
      problem = Problem
        .readables(team: self.current_team!)
        .find_by(code: code)

      raise RecordNotExists.new(Problem, code: code) if problem.nil?

      Acl.permit!(mutation: self, args: { problem: problem })

      problem_body = problem.body.readable(team: self.current_team!)

      if problem.destroy
        { problem: problem, problem_body: problem_body }
      else
        add_errors(problem)
      end
    end
  end
end
