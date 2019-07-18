# frozen_string_literal: true

module Mutations
  class ApplyScore < GraphQL::Schema::RelayClassicMutation
    field :score,  Types::ScoreType, null: true
    field :errors, [String],         null: false

    argument :answer_id, ID,      required: true
    argument :point,     Integer, required: true

    def resolve(answer_id:, point:)
      answer = Answer.find_by!(id: answer_id)
      Acl.permit!(mutation: self, args: {})

      # gradeでscoreレコードが作られる
      if answer.grade(point: point)
        { score: answer.score.readable, errors: [] }
      else
        { errors: answer.score.errors.full_messages }
      end
    end
  end
end
