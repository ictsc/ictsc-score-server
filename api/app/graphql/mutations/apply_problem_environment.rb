# frozen_string_literal: true

module Mutations
  class ApplyProblemEnvironment < BaseMutation
    field :problem_environment, Types::ProblemEnvironmentType, null: true

    # find key
    argument :problem_code, String,  required: true
    argument :team_number,  Integer, required: false
    argument :name,         String,  required: true
    argument :service,      String,  required: true

    # value
    argument :status,       String,  required: true
    argument :host,         String,  required: true
    argument :port,         Integer, required: true
    argument :user,         String,  required: true
    argument :password,     String,  required: true
    argument :secret_text,  String,  required: true

    # 通知無効
    argument :silent,       Boolean, required: false

    # team_numberがnilなら共通として扱う
    def resolve(problem_code:, team_number:, name:, service:, status:, host:, port:, user:, password:, secret_text:, silent: false)
      Acl.permit!(mutation: self, args: {})

      problem = Problem.find_by(code: problem_code)
      raise RecordNotExists.new(Problem, code: problem_code) if problem.nil?

      team = Team.find_by(number: team_number)
      raise RecordNotExists.new(Team, number: team_number) if !team_number.nil? && team.nil?

      p_env = ProblemEnvironment.find_or_initialize_by(problem: problem, team: team, name: name, service: service)

      if p_env.update(status: status, host: host, port: port, user: user, password: password, secret_text: secret_text)
        Notification.notify(mutation: self.graphql_name, record: p_env) unless silent
        { problem_environment: p_env.readable(team: self.current_team!) }
      else
        add_errors(p_env)
      end
    end
  end
end
