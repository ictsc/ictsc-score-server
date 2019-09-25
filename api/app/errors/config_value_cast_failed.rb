# frozen_string_literal: true

class ConfigValueCastFailed < StandardError
  def initialize(record)
    super("key: #{record.key}, value_type: #{record.value}, value: #{record.value_type}")
  end
end
