# frozen_string_literal: true

class UnhandledProblemBodyMode < StandardError
  def initialize(mode)
    super("unhandled mode #{mode.inspect}")
  end
end
