# frozen_string_literal: true

class IssueComment < ApplicationRecord
  validates :text,       presence: true
  validates :from_staff, boolean: true
  validates :issue,      presence: true

  # コメント追加時にIssue#statusが変化したら同時にsaveする
  belongs_to :issue, autosave: true
end
