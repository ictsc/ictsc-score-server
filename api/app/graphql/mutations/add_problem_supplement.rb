# frozen_string_literal: true

module Mutations
  class AddProblemSupplement < GraphQL::Schema::RelayClassicMutation
    field :problem_supplement, Types::ProblemSupplementType, null: true
    field :errors, [String], null: false

    argument :text, String, required: true
    argument :problem_id, ID, required: true

    def resolve(text:, problem_id:)
      Acl.permit!(mutation: self, args: {})

      problem_supplement = ProblemSupplement.new

      if problem_supplement.update(text: text, problem: Problem.find!(problem_id))
        { problem_supplement: problem_supplement.readable, errors: [] }
      else
        { errors: problem_supplement.errors.full_messages }
      end
    end
  end
end
