# frozen_string_literal: true

class UnhandledClass < StandardError
  def initialize(klass)
    super("unhandled class #{klass}")
  end
end
