# frozen_string_literal: true

class Category < ApplicationRecord
  validates :code,        presence: true, uniqueness: true
  validates :title,       allow_empty: true
  validates :description, allow_empty: true, length: { maximum: 8192 }
  validates :order,       presence: true

  has_many :problems, dependent: :nullify
end
