# frozen_string_literal: true

class Answer < ApplicationRecord
  validates :bodies,     presence: true
  validates :confirming, boolean:  true
  validates :problem,    presence: true, uniqueness: { scope: %i[team_id created_at] }
  validates :team,       presence: true
  validates :score,      presence: false

  belongs_to :problem
  belongs_to :team
  has_one :score, dependent: :destroy, autosave: true
  has_one :first_correct_answer, dependent: :destroy, autosave: false

  validate :validate_bodies_format

  def validate_bodies_format
    # TODO: 実装までの応急処置
    # rubocop:disable Lint/EmptyWhen
    case problem.body.mode
    when 'textbox'
    when 'radio_button'
    when 'checkbox'
    else
      raise ProblemBodyUnhandledMode, problem.body.mode
    end
    # rubocop:enable Lint/EmptyWhen
  end

  # ProblemBody#modeに従って採点を行いScoreレコードを作成する
  # 手動採点なら引数で値を渡す。
  # 自動採点なら渡さない
  # 失敗したらfalseが返る
  def grade!(point: nil, solved: nil)
    self.score ||= Score.new

    case problem.body.mode
    when 'textbox'
      score.attributes = { point: point, solved: solved }
    when 'radio_button', 'checkbox'
      if !point.nil? && !solved.nil?
        score.errors.add(:grading, "in #{problem.body.mode}, disallow grade manually")
        return false
      end

      correct_count = problem.body.corrects.zip(bodies).count {|correct, body| Set.new(correct) == Set.new(body) }

      # パーセンテージ(整数)で保持するため端数は切り捨て
      score.point = 100 * correct_count / problem.body.corrects.size
      score.solved = score.point == 100
    else
      raise ProblemBodyUnhandledMode, problem.body.mode
    end

    score.save
  end

  class << self
    def delay_filter
      # created_at <= Time.current - Config.grading_delay_sec.seconds
      where(created_at: Time.zone.at(0)..(Time.current - Config.grading_delay_sec.seconds))
    end

    def find_actual_fca(team:, problem:)
      where(team: team, problem: problem)
        .joins(:score)
        .where(scores: { solved: true })
        .order(:created_at)
        .first
    end
  end
end
