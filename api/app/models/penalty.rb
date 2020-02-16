# frozen_string_literal: true

class Penalty < ApplicationRecord
  # compiste unique index
  validates :problem,    presence: true, uniqueness: { scope: %i[team_id] }
  validates :team,       presence: true
  validates :count,      presence: true

  belongs_to :problem
  belongs_to :team
end
