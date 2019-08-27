# frozen_string_literal: true

module Types
  class IssueCommentType < Types::BaseObject
    field :id,         ID,              null: false
    field :issue_id,   ID,              null: false
    field :text,       String,          null: false
    field :from_staff, Boolean,         null: false
    field :created_at, Types::DateTime, null: false
  end
end
