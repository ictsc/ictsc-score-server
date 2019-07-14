# frozen_string_literal: true

class UnhandledProblemBodyMode < StandardError
  attr_reader :mode

  def initialize(mode)
    @type = mode
    super("unhandled mode #{mode}")
  end
end
