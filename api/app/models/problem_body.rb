# frozen_string_literal: true

class ProblemBody < ApplicationRecord
  validates :mode,             presence: true
  validates :title,            presence: true
  validates :genre,            allow_empty: true
  validates :text,             presence: true
  validates :perfect_point,    presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0   }
  validates :solved_criterion, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 50, less_than_or_equal_to: 100 }
  validates :problem,          presence: true
  validates :candidates,       allow_empty: true
  validates :corrects,         allow_empty: true, answer_bodies: true

  belongs_to :problem

  enum mode: {
    textbox: 10,
    radio_button: 20,
    checkbox: 30
  }

  validate :validate_candidates

  after_commit :regrade_answers, on: %i[update], if: :require_regrade_answer?

  # フォーマットの詳細は該当スペックを参照
  def validate_candidates # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    case mode
    when 'textbox'
      errors.add(:candidates, "in #{mode} mode, candidates must be []") unless candidates == []
    when 'radio_button', 'checkbox'
      # 長さ1以上の配列で、全要素がArrayで、それら全てが2つ以上の空でないStringのみで構成されているなら有効
      # [['foo', 'bar']]

      if !candidates.is_a?(Array) || candidates.empty? || candidates.any? {|cand| !cand.is_a?(Array) || cand.size < 2 }
        # nil, '', 10, [], [[]], ['hoge'], [['hoge']]
        errors.add(:candidates, "in #{mode} mode, candidates must be [[String, String, ...], ...]")
      elsif candidates.any? {|cand| cand.any? {|elem| !elem.is_a?(String) || elem.empty? } }
        # [[1, 2.2]], [['', 'hoge']]
        errors.add(:candidates, "in #{mode} mode, candidates elements must be none empty string")
      elsif candidates.any? {|cand| cand.size != cand.uniq.size }
        # [['hoge', 'hoge']]
        errors.add(:candidates, "in #{mode} mode, candidates elements must be unique")
      end
    else
      raise UnhandledProblemBodyMode, mode
    end
  end

  def require_regrade_answer?
    # これらが変更されていたら再採点する必要がある
    # 正解の選択肢の変更には対応するがcandidates自体の変更には対応しない(解答の書き換えが必要なため)
    # saved_changesはafter_*で有効
    (saved_changes.keys & %w[perfect_point solved_criterion corrects]).present?
  end

  def regrade_answers
    failed_count = problem.regrade_answers

    # after_commit後にerrorsを追加するのは違和感があるが、Mutationのエラーハンドリングが手軽
    unless failed_count.zero?
      message = "failed to regrade #{failed_count} answer "
      errors.add(:regrade_answers, message)

      # 本来は失敗しないはずの処理なのでBugsnagにも通知しておく
      Bugsnag.notify(StandardError.new(message))
    end
  end
end
