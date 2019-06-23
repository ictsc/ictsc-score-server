# frozen_string_literal: true

class Category < ApplicationRecord
  validates :code,        presence: true, uniqueness: true
  validates :title,       presence: true
  validates :description, allow_empty: true, length: { maximum: 8192 }
  validates :order,       presence: true

  has_many :problems, dependent: :nullify
end
