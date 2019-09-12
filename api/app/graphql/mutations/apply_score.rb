# frozen_string_literal: true

module Mutations
  class ApplyScore < BaseMutation
    field :score,  Types::ScoreType, null: true

    argument :answer_id, ID,      required: true
    argument :percent,   Integer, required: false

    def resolve(answer_id:, percent: nil)
      answer = Answer.find_by(id: answer_id)
      raise RecordNotExists.new(Answer, id: answer_id) if answer.nil?

      Acl.permit!(mutation: self, args: {})

      # gradeでscoreレコードが作られる
        { score: answer.score.readable(team: self.current_team!) }
      if answer.grade(percent: percent)
      else
        add_errors(answer.score)
      end
    end
  end
end
