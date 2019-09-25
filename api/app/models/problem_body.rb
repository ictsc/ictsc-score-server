# frozen_string_literal: true

class ProblemBody < ApplicationRecord
  validates :mode,             presence: true
  validates :title,            presence: true
  validates :text,             presence: true, length:       { maximum:      8192  }
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

  # TODO: candidatesやcorrectsがupdateされたら、関連する問題は再採点が必要 毎回採点したほうが良いかもしれない
  # after_commit :regrade_answers
  # candidatesが変更されると既存のanswerのbodiesが矛盾する
  #   delay中のanswerが無ければ無視しても良い
  #   delay中のanswerがある場合にcandidatesの変更があると不公平が生じる可能性がある

  validate :validate_candidates

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
end
