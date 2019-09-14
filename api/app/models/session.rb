# frozen_string_literal: true

class Session
  PREFIX = 'sessions:'

  class << self
    def keys
      redis.keys("#{PREFIX}*")
    end

    def all
      keys.map do |key|
        value = Marshal.load(redis.get(key)) # rubocop:disable Security/MarshalLoad
        OpenStruct.new(id: key.sub(/^#{PREFIX}/, ''), team_id: value['team_id'])
      end
    end

    def where(team_id:)
      all.select {|session| session[:team_id] == team_id }
    end

    def destroy_all
      redis.del(keys)
    end

    def destroy(id:)
      redis.del("#{PREFIX}#{id}")
    end

    def destroy_by(team_id:)
      keys = where(team_id: team_id).map(&:id).map(&PREFIX.method(:+))
      redis.del(keys) if keys.present?
    end

    private

    def redis
      Redis.current
    end
  end
end
