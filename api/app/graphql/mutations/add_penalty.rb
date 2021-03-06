# frozen_string_literal: true

module Mutations
  class AddPenalty < BaseMutation
    field :penalty, Types::PenaltyType, null: true

    argument :problem_id, ID, required: true

    # 初回のレコードが無いときはfromは無視する
    def resolve(problem_id:)
      problem = Problem.find_by(id: problem_id)
      raise RecordNotExists.new(Problem, id: problem_id) if problem.nil?

      args = { problem: problem }
      Acl.permit!(mutation: self, args: args)

      penalty = Penalty.new

      if penalty.update(args.merge(team: self.current_team!))
        # Notification.notify(mutation: self.graphql_name, record: penalty)

        { penalty: penalty.readable(team: self.current_team!) }
      else
        add_errors(penalty)
      end
    end
  end
end
