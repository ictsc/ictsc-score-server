# frozen_string_literal: true

class ConflictPenaltyUpdate < GraphQL::ExecutionError
  def initialize(problem_code:, team_number:, from:, to:)
    super("conflict penalty(#{problem_code}, #{team_number}) update to #{to} from #{from}")
  end
end
