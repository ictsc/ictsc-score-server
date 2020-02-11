# frozen_string_literal: true

module Mutations
  class ApplyScore < BaseMutation
    field :answer, Types::AnswerType, null: true

    argument :answer_id, ID,      required: true
    argument :percent,   Integer, required: false

    def resolve(answer_id:, percent: nil)
      answer = Answer.find_by(id: answer_id)
      raise RecordNotExists.new(Answer, id: answer_id) if answer.nil?

      Acl.permit!(mutation: self, args: {})

      # gradeでscoreレコードが作られる
      if answer.grade(percent: percent)
        Notification.notify(mutation: self.mutation_name, record: answer)
        { answer: answer.readable(team: self.current_team!) }
      else
        add_errors(answer.score)
      end
    end
  end
end
