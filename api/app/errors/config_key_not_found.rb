# frozen_string_literal: true

class ConfigKeyNotFound < StandardError
  def initialize(key)
    super(key.inspect)
  end
end
