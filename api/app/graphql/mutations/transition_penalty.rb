# frozen_string_literal: true

module Mutations
  class TransitionPenalty < BaseMutation
    field :penalty, Types::PenaltyType, null: true

    argument :problem_id, ID,      required: true
    argument :team_id,    ID,      required: true
    argument :from,       Integer, required: true
    argument :to,         Integer, required: true

    # 初回のレコードが無いときはfromは無視する
    def resolve(problem_id:, team_id:, from:, to:)
      Acl.permit!(mutation: self, args: {})

      problem = Problem.find_by(id: problem_id)
      raise RecordNotExists.new(Problem, id: problem_id) if problem.nil?

      team = Team.find_by(id: team_id)
      raise RecordNotExists.new(Team, id: team_id) if team.nil?

      penalty = Penalty.find_or_initialize_by(problem: problem, team: team)

      raise ConflictPenaltyUpdate.new(problem_id: problem_id, team_id: team_id, from: from, to: to) if penalty.count != from && !penalty.count.nil?

      if penalty.update(count: to)
        Notification.notify(mutation: self.graphql_name, record: penalty)

        { penalty: penalty.readable(team: self.current_team!) }
      else
        add_errors(penalty)
      end
    end
  end
end
