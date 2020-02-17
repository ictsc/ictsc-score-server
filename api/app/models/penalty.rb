# frozen_string_literal: true

class Penalty < ApplicationRecord
  # compiste unique index
  validates :problem,    presence: true, uniqueness: { scope: %i[team_id created_at] }
  validates :team,       presence: true

  belongs_to :problem
  belongs_to :team
end
