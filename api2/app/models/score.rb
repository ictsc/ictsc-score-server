# frozen_string_literal: true

class Score < ApplicationRecord
  # nil or 得点率
  validates :point,  presence: false, length: { minimum: 0, maximum: 100 }
  validates :solved, boolean: true
  validates :answer, presence: true, uniqueness: { scope: %i[team_id created_at] }

  belongs_to :answer
  has_one :team, through: :answer
  has_one :problem, through: :answer

  after_save :refresh_first_correct_answer, if: :saved_change_to_correct?

  def refresh_first_correct_answer
    # TODO: 親トランザクションやらなんやらが影響しそう after_commitにするのはうかつ
    ActiveRecord::Base.transaction do
      FirstCorrectAnswer.find_by(team: team, problem: problem)&.destroy!
      actual_fca = Answer.find_actual_fca(team: team, problem: problem)
      FirstCorrectAnswer.create!(team: team, problem: problem, answer: actual_fca) unless actual_fca.nil?
    end
  end
end
