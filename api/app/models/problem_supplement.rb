# frozen_string_literal: true

class ProblemSupplement < ApplicationRecord
  validates :text,    presence: true
  validates :problem, presence: true

  belongs_to :problem
end
