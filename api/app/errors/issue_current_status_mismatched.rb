# frozen_string_literal: true

class IssueCurrentStatusMismatched < GraphQL::ExecutionError
  def initialize(expected:, got:)
    super("issue's current status expected: #{expected}, got: #{got}")
  end
end
