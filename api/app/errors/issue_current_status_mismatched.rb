# frozen_string_literal: true

class IssueCurrentStatusMismatched < GraphQL::ExecutionError
  def initialize(expected:, got:)
    super("issue's current status expected: #{expected.inspect}, got: #{got.inspect}")
  end
end
