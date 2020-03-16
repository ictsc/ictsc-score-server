# frozen_string_literal: true

class Category < ApplicationRecord
  validates :code,        presence: true, uniqueness: true
  validates :title,       allow_empty: true
  validates :description, allow_empty: true
  validates :order,       presence: true

  has_many :problems, dependent: :nullify

  class << self
    # デバッグ用ショートハンド
    def code(code)
      self.find_by(code: code)
    end
  end
end
