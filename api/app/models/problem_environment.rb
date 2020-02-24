# frozen_string_literal: true

class ProblemEnvironment < ApplicationRecord
  # インターフェースから見るとname, service, team, problemが複合プライマリーキー
  validates :problem,  presence: true, uniqueness: { scope: %i[team_id name service] }
  # teamがnilなら共通
  validates :team,     presence: false
  validates :name,     presence: true
  validates :service,  presence: true

  validates :status,   presence: false
  validates :host,     presence: false
  validates :port,     presence: true, numericality: { only_integer: true }
  validates :user,     presence: false
  validates :password,    allow_empty: true, length: { maximum: 8192 }
  validates :secret_text, allow_empty: true, length: { maximum: 8192 }

  belongs_to :team, optional: true
  belongs_to :problem
end
