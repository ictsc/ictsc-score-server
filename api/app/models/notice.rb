# frozen_string_literal: true

class Notice < ApplicationRecord
  validates :title,       presence: true
  validates :text,        presence: true
  validates :pinned,      boolean: true
  validates :team,        presence: false

  belongs_to :team, optional: true
end
