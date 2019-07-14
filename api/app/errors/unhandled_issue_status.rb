# frozen_string_literal: true

class UnhandledIssueStatus < StandardError
  attr_reader :status

  def initialize(status)
    @type = status
    super("unhandled status #{status}")
  end
end
