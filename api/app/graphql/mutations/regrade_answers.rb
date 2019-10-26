# frozen_string_literal: true

module Mutations
  class RegradeAnswers < BaseMutation
    field :answers,   [Types::AnswerType], null: false
    field :total,     Integer,             null: false
    field :succeeded, Integer,             null: false
    field :failed,    Integer,             null: false

    argument :problem_id, ID, required: true

    def resolve(problem_id:)
      problem = Problem.find_by(id: problem_id)
      raise RecordNotExists.new(Problem, id: problem_id) if problem.nil?

      Acl.permit!(mutation: self, args: { problem: problem })

      failed = problem.regrade_answers {|answer| add_errors(answer.score) }

      {
        answers: problem.answers,
        total: problem.answers.size,
        succeeded: problem.answers.size - failed,
        failed: failed
      }
    end
  end
end
