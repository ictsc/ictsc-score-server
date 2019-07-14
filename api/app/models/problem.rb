# frozen_string_literal: true

class Problem < ApplicationRecord
  validates :code,             presence: true, uniqueness: true
  validates :writer,           disallow_empty: true
  validates :secret_text,      allow_empty: true, length: { maximum: 8192 }
  validates :body,             presence: false
  validates :open_at,          daterange: true, allow_nil: true
  validates :order,            presence: true
  validates :team_isolate,     boolean: true
  validates :previous_problem, presence: false
  validates :category,         presence: false

  belongs_to :previous_problem, class_name: 'Problem', optional: true
  belongs_to :category, optional: true
  has_one  :body,                  dependent: :destroy, class_name: 'ProblemBody', autosave: true
  has_many :environments,          dependent: :destroy, class_name: 'ProblemEnvironment'
  has_many :supplements,           dependent: :destroy, class_name: 'ProblemSupplement'
  has_many :answers,               dependent: :destroy
  has_many :issues,                dependent: :destroy
  has_many :first_correct_answers, dependent: :destroy

  def opened?(team:)
    self.class.opened(team: team).exists?(id: self.id)
  end

  def latest_answer_created_at(team:)
    answer.where(team: team).order(:created_at).last&.created_at || Time.zone.at(0)
  end

  class << self
    def opened(team:)
      return all if Config.all_problem_force_open_at <= Time.current

      filter_by_previous_problem(team: team).filter_by_open_at
    end

    # 依存問題的に見えるかどうか
    def filter_by_previous_problem(team:)
      all_team_fcas = FirstCorrectAnswer.delay_filter
      my_team_fcas = all_team_fcas.where(team: team)

      # 依存問題がない
      # 自チームが依存問題を解決
      # 他チームが依存問題を解決していてteam_isolate == false
      where(previous_problem: nil)
        .or(where(previous_problem: my_team_fcas))
        .or(where(previous_problem: all_team_fcas, team_isolate: false))
    end

    # 公開期間的に見えるかどうか
    def filter_by_open_at
      # 公開期間がnilか公開期間内なら見れる
      where(open_at: nil)
        .or(where('open_at @> ?::timestamp', Time.current))
    end
  end
end
