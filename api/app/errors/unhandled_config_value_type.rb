# frozen_string_literal: true

class UnhandledConfigValueType < StandardError
  def initialize(value_type)
    super("unhandled config value type #{value_type.inspect}")
  end
end
