# frozen_string_literal: true

module Mutations
  class ApplyScore < GraphQL::Schema::RelayClassicMutation
    field :score,  Types::ScoreType, null: true
    field :errors, [String],         null: false

    argument :answer_id, ID,      required: true
    argument :point,     Integer, required: true
    argument :solved,    Boolean, required: true

    def resolve(answer_id:, point:, solved:)
      answer = Answer.find_by!(id: answer_id)
      Acl.permit!(mutation: self, args: {})

      # grade!でscoreレコードが作られる
      if answer.grade(point: point, solved: solved)
        { score: answer.score.readable, errors: [] }
      else
        { errors: answer.score.errors.full_messages }
      end
    end
  end
end
