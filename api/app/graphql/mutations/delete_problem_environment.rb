# frozen_string_literal: true

module Mutations
  class DeleteProblemEnvironment < BaseMutation
    field :problem_environment, Types::ProblemEnvironmentType, null: true

    argument :problem_supplement_id, ID, required: true

    def resolve(problem_supplement_id:)
      problem_environment = ProblemEnvironment.find_by(id: problem_supplement_id)
      raise RecordNotExists.new(ProblemEnvironment, id: problem_supplement_id) if problem_environment.nil?

      Acl.permit!(mutation: self, args: { problem_environment: problem_environment })

      if problem_environment.destroy
        # 削除されたレコードはreadableが使えないのでカラムのみフィルタする
        { problem_environment: problem_environment.filter_columns(team: self.current_team!) }
      else
        add_errors(problem_environment)
      end
    end
  end
end
