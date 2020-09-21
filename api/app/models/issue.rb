# frozen_string_literal: true

class Issue < ApplicationRecord
  validates :status,  presence: true
  validates :problem, presence: true, uniqueness: { scope: :team_id }
  validates :team,    presence: true

  # 状態遷移条件
  # unsolved: 未対応
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

  # staff以外には対応中を未対応と表示する
  def response_status(team:)
    return 'unsolved' if !team.staff? && in_progress?

    status
  end

  def transition_by_click(team:)
    case status
    when 'unsolved'
      self.status = team.staff? ? 'in_progress' : 'solved'
    when 'in_progress'
      self.status = 'solved'
    when 'solved'
      self.status = team.staff? ? 'in_progress' : 'unsolved'
    else
      raise UnhandledIssueStatus, status
    end
  end

  def transition_by_comment(team:)
    case status
    when 'unsolved'
      self.status = 'in_progress' if team.staff?
    when 'in_progress'
      self.status = 'unsolved' if team.player?
    when 'solved'
      self.status = 'unsolved' if team.player?
    else
      raise UnhandledIssueStatus, status
    end
  end
end
