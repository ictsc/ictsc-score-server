# frozen_string_literal: true

module Mutations
  class DeleteProblemSupplement < GraphQL::Schema::RelayClassicMutation
    field :errors, [String], null: false

    argument :problem_supplement_id, ID, required: true

    def resolve(problem_supplement_id:)
      problem_supplement = ProblemSupplement.find!(problem_supplement_id)
      Acl.permit!(mutation: self, args: { problem_supplement: problem_supplement })

      if problem_supplement.destroy
        # errorsが空なら成功とする
        { errors: [] }
      else
        { errors: problem_supplement.errors.full_messages }
      end
    end
  end
end
