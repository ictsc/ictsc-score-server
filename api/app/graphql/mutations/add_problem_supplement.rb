# frozen_string_literal: true

module Mutations
  class AddProblemSupplement < BaseMutation
    field :problem_supplement, Types::ProblemSupplementType, null: true

    argument :problem_code, String, required: true
    argument :text, String, required: true

    def resolve(problem_code:, text:)
      Acl.permit!(mutation: self, args: {})
      problem = Problem.find_by(code: problem_code)
      raise RecordNotExists.new(Problem, code: problem_code) if problem.nil?

      problem_supplement = ProblemSupplement.new

      if problem_supplement.update(text: text, problem: problem)
        { problem_supplement: problem_supplement.readable }
      else
        add_errors(problem_supplement)
      end
    end
  end
end
