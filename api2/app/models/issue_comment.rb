# frozen_string_literal: true

class IssueComment < ApplicationRecord
  validates :text,       presence: true, length: { maximum: 8192 }
  validates :from_staff, boolean: true
  validates :issue,      presence: true

  belongs_to :issue
end
