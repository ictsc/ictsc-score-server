# frozen_string_literal: true

module Mutations
  class ApplyProblemEnvironment < GraphQL::Schema::RelayClassicMutation
    field :problem_environment, Types::ProblemEnvironmentType, null: true
    field :errors, [String], null: false

    # find key
    argument :problem_code, String,  required: true
    argument :team_number,  Integer, required: true

    # value
    argument :status,   String, required: true
    argument :host,     String, required: true
    argument :user,     String, required: true
    argument :password, String, required: true

    def resolve(problem_code:, team_number:, status:, host:, user:, password:)
      Acl.permit!(mutation: self, args: {})

      problem = Problem.find_by!(code: problem_code)
      team = Team.find_by!(number: team_number)
      p_env = ProblemEnvironment.find_or_initialize_by(problem: problem, team: team)

      if p_env.update(status: status, host: host, user: user, password: password)
        { problem_environment: p_env.readable, errors: [] }
      else
        { errors: p_env.errors.full_messages }
      end
    rescue StandardError => e
      raise GraphQL::ExecutionError, e.message
    end
  end
end
