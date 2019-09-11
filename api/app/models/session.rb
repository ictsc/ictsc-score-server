# frozen_string_literal: true

class Session < ApplicationRecord
  self.abstract_class = true
  PREFIX = 'sessions:'

  class << self
    def redis
      Redis.current
    end

    def keys
      redis.keys("#{PREFIX}*")
    end

    def all
      keys.map do |key|
        value = Marshal.load(redis.get(key)) # rubocop:disable Security/MarshalLoad
        OpenStruct.new(id: key.delete(PREFIX), team_id: value['team_id'])
      end
    end

    def none
      []
    end

    def destroy(id:)
      redis.del("#{PREFIX}#{id}")
    end

    def destroy_all
      redis.del(keys)
    end
  end
end
