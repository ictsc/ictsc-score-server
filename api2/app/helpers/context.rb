# frozen_string_literal: true

require 'singleton'

# 様々な場所からGraphQLのcontextと同等のものにアクセスするためのクラス
class Context
  include Singleton
  class_attribute :context

  class << self
    def current_team!
      context.fetch(:current_team)
    end
  end
end
