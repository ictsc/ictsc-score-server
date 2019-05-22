# frozen_string_literal: true

class ProblemSupplement < ApplicationRecord
  validates :text,    presence: true, length: { maximum: 8192 }
  validates :problem, presence: true

  belongs_to :problem
end
