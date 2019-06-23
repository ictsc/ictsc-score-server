# frozen_string_literal: true

module Types
  class BaseEnum < GraphQL::Schema::Enum
    class << self
      def values_from(enum)
        enum.keys.each {|key| self.value(key) }
      end
    end
  end
end
