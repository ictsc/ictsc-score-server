# frozen_string_literal: true

module Mutations
  class ApplyProblemEnvironment < BaseMutation
    field :problem_environment, Types::ProblemEnvironmentType, null: true

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

      problem = Problem.find_by(code: problem_code)
      raise RecordNotExists.new(Problem, code: problem_code) if problem.nil?

      team = Team.find_by(number: team_number)
      raise RecordNotExists.new(Team, number: team_number) if team.nil?

      p_env = ProblemEnvironment.find_or_initialize_by(problem: problem, team: team)

      if p_env.update(status: status, host: host, user: user, password: password)
        { problem_environment: p_env.readable(team: self.context.current_team!) }
      else
        add_errors(p_env)
      end
    end
  end
end
