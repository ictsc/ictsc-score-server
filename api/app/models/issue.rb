# frozen_string_literal: true

class Issue < ApplicationRecord
  validates :title,   presence: true
  validates :status,  presence: true
  validates :problem, presence: true
  validates :team,    presence: true

  # 状態遷移条件
  # unsolved: 初期値
  # in_progress: playerが操作, solvedだったissueに新しくコメントが付く
  # solved: playerかstaff操作
  # in_progress時にstaffがボタンを押した場合はsolvedになるのかunsolvedになるのか
  # やっぱ unsolved<->solved, in_progress<->not_in_progressで分けたほうが良さそう
  enum status: {
    unsolved: 1,
    in_progress: 2,
    solved: 3
  }

  belongs_to :problem
  belongs_to :team
  has_many :comments, dependent: :destroy, class_name: 'IssueComment'
end
