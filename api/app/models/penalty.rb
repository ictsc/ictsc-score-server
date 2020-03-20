# frozen_string_literal: true

class Penalty < ApplicationRecord
  # compiste unique index
  validates :problem,    presence: true, uniqueness: { scope: %i[team_id created_at] }
  validates :team,       presence: true
  validate :reject_not_resettable

  belongs_to :problem
  belongs_to :team

  def reject_not_resettable
    errors.add(:problem, 'this problem is not resettable') unless self.problem.body.resettable
  end
end
