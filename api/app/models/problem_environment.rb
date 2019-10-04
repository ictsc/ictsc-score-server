# frozen_string_literal: true

class ProblemEnvironment < ApplicationRecord
  validates :status,   presence: false
  validates :host,     presence: false
  validates :user,     presence: false
  validates :password, presence: false
  validates :note,     disallow_empty: true, length: { maximum: 8192 }

  belongs_to :team
  belongs_to :problem
end
