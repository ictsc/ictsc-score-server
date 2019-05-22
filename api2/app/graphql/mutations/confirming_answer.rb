# frozen_string_literal: true

module Mutations
  class ConfirmingAnswer < GraphQL::Schema::RelayClassicMutation
    field :answer, Types::AnswerType, null: true
    field :errors, [String], null: false

    argument :answer_id, ID, required: true
    argument :confirming, Boolean, required: true

    def resolve(answer_id:, confirming:)
      Acl.permit!(mutation: self, args: {})

      answer = Answer.find!(answer_id)

      if answer.update(confirming: confirming)
        { answer: answer.readable, errors: [] }
      else
        { errors: answer.errors.full_messages }
      end
    end
  end
end
