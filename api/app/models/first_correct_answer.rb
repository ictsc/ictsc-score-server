# frozen_string_literal: true

# 各チームの各問題の最初の正答を記録する
class FirstCorrectAnswer < ApplicationRecord
  validates :answer,  presence: true
  validates :problem, presence: true, uniqueness: { scope: :team_id }
  validates :team,    presence: true

  belongs_to :answer
  belongs_to :problem
  belongs_to :team

  validate :valid_relation

  def valid_relation
    errors.add(:answer, '.team not same as team') if team != answer.team
    errors.add(:answer, '.problem not same as problem') if problem != answer.problem
  end

  class << self
    def delay_filter
      where(answer: Answer.delay_filter)
    end
  end
end
