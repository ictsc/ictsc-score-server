# frozen_string_literal: true

module Mutations
  class DeleteProblem < BaseMutation
    field :problem, Types::ProblemType, null: false
    field :problem_body, Types::ProblemBodyType, null: false
    argument :code, String, required: true

    def resolve(code:)
      problem = Problem.find_by(code: code)
      raise RecordNotExists.new(Problem, code: code) if problem.nil?

      Acl.permit!(mutation: self, args: { problem: problem })

      problem_body = problem.body

      if problem.destroy
        # 削除されたレコードはreadableが使えないのでカラムのみフィルタする
        { problem: problem.filter_columns(team: self.current_team!), problem_body: problem_body.filter_columns(team: self.current_team!) }
      else
        add_errors(problem)
      end
    end
  end
end
