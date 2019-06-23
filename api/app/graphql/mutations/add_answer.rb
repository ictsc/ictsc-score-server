# frozen_string_literal: true

module Mutations
  class AddAnswer < GraphQL::Schema::RelayClassicMutation
    field :answer, Types::AnswerType, null: true
    field :errors, [String], null: false

    argument :problem_id, ID, required: true
    argument :bodies, [[String]], required: true

    def resolve(problem_id:, bodies:)
      args = { problem: Problem.find!(problem_id) }
      Acl.permit!(mutation: self, args: args)

      answer = Answer.new

      if answer.update(args.merge(bodies: bodies, confirming: false, team: Context.current_team!))
        # TODO: answer.grade!をジョブで実行する -> after create hook
        { answer: answer.readable, errors: [] }
      else
        { errors: answer.errors.full_messages }
      end
    end
  end
end
