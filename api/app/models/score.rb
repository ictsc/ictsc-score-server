# frozen_string_literal: true

class Score < ApplicationRecord
  # nil or 得点率
  validates :point,   presence: false, allow_nil: true
  validates :percent, presence: false, allow_nil: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :solved,  boolean: true
  validates :answer,  presence: true, uniqueness: true

  belongs_to :answer
  has_one :team, through: :answer
  has_one :problem, through: :answer

  # NOTE: JANOG47 NETCON では使用せず
  after_save :refresh_first_correct_answer, if: :saved_change_to_solved?

  def refresh_first_correct_answer
    # TODO: 親トランザクションやらなんやらが影響しそう after_commitにするのはうかつ
    # TODO: point.nil? 考慮
    ActiveRecord::Base.transaction do
      FirstCorrectAnswer.find_by(team: team, problem: problem)&.destroy!
      actual_fca = Answer.find_actual_fca(team: team, problem: problem)
      FirstCorrectAnswer.create!(team: team, problem: problem, answer: actual_fca) unless actual_fca.nil?
    end
  end
end
