# frozen_string_literal: true

class Notice < ApplicationRecord
  validates :title,       presence: true
  validates :text,        presence: true, length: { maximum: 8192 }
  validates :pinned,      boolean: true
  validates :target_team, presence: false

  belongs_to :target_team, class_name: 'Team', optional: true
end
