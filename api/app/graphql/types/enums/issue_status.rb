# frozen_string_literal: true

module Types
  module Enums
    class IssueStatus < Types::BaseEnum
      values_from Issue.statuses
    end
  end
end
