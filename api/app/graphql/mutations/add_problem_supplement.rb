# frozen_string_literal: true

module Mutations
  class AddProblemSupplement < BaseMutation
    field :problem_supplement, Types::ProblemSupplementType, null: true

    argument :text, String, required: true
    argument :problem_id, ID, required: true

    def resolve(text:, problem_id:)
      Acl.permit!(mutation: self, args: {})
      problem = Problem.find_by(id: problem_id)
      raise RecordNotExists.new(Problem, id: problem_id) if problem.nil?

      problem_supplement = ProblemSupplement.new

      if problem_supplement.update(text: text, problem: problem)
        { problem_supplement: problem_supplement.readable }
      else
        add_errors(problem_supplement)
      end
    end
  end
end
