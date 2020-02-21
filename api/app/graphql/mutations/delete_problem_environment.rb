# frozen_string_literal: true

module Mutations
  class DeleteProblemEnvironment < BaseMutation
    field :problem_environment, Types::ProblemEnvironmentType, null: true

    argument :problem_environment_id, ID, required: true

    def resolve(problem_environment_id:)
      # 削除時は事前にフィルタする必要がある
      problem_environment = ProblemEnvironment
        .readables(team: self.current_team!)
        .find_by(id: problem_environment_id)

      raise RecordNotExists.new(ProblemEnvironment, id: problem_environment_id) if problem_environment.nil?

      Acl.permit!(mutation: self, args: { problem_environment: problem_environment })

      if problem_environment.destroy
        { problem_environment: problem_environment }
      else
        add_errors(problem_environment)
      end
    end
  end
end
