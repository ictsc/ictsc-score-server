# frozen_string_literal: true

class UnhandledClass < StandardError
  attr_reader :klass

  def initialize(klass)
    @klass = klass
    super("unhandled class #{klass}")
  end
end
