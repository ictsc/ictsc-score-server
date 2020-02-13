# frozen_string_literal: true

class ProblemEnvironment < ApplicationRecord
  # インターフェースから見るとname, team, problemが複合プライマリーキー
  validates :problem,  presence: true, uniqueness: { scope: %i[team_id name] }
  # teamがnilなら共通
  validates :team,     presence: false
  validates :name,     presence: true

  validates :status,   presence: false
  validates :host,     presence: false
  validates :user,     presence: false
  validates :password, presence: false
  validates :note,     disallow_empty: true, length: { maximum: 8192 }

  belongs_to :team, optional: true
  belongs_to :problem
end
