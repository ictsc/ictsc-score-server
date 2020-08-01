# frozen_string_literal: true

class UnhandledIssueStatus < StandardError
  def initialize(status)
    super("unhandled status #{status.inspect}")
  end
end
