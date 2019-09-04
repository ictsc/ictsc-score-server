# frozen_string_literal: true

require 'singleton'

# TODO: deprecated
# 様々な場所からGraphQLのcontextと同等のものにアクセスするためのクラス
class Context
  include Singleton

  class << self
    # スレッドが使い回されても毎回 /api/graphql で初期化上書きされるので平気だが、
    # これ使ったほうが良い https://github.com/steveklabnik/request_store
    def context
      Thread.current[:request]
    end

    def context=(value)
      Thread.current[:request] = value
    end

    def current_team!
      context.fetch(:current_team)
    end
  end
end
