# frozen_string_literal: true

class Issue < ApplicationRecord
  validates :status,  presence: true
  validates :problem, presence: true, uniqueness: { scope: :team_id }
  validates :team,    presence: true

  # 状態遷移条件
  # unsolved: 要対応
  # in_progress: 対応中
  # solved: 解決
  enum status: {
    unsolved: 1,
    in_progress: 2,
    solved: 3
  }

  belongs_to :problem
  belongs_to :team
  has_many :comments, dependent: :destroy, class_name: 'IssueComment'
end
