# frozen_string_literal: true

class Session
  PREFIX = 'sessions:'

  class << self
    def keys
      redis.keys("#{PREFIX}*")
    end

    def all
      keys
        .map {|key| get(key) }
        .compact
    end

    def find_by(id:)
      get("#{PREFIX}#{id}")
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

    def get(key)
      raw_value = redis.get(key)
      return nil unless raw_value

      value = Marshal.load(raw_value) # rubocop:disable Security/MarshalLoad
      # ログアウトさせられたユーザーがその状態でアクセスすると{}が登録される
      return nil if value.blank?

      OpenStruct.new(
        id: key.sub(/^#{PREFIX}/, ''),
        team_id: value['team_id'],
        latest_ip: value['latest_ip'],
        created_at: value['created_at'],
        updated_at: value['updated_at']
      )
    end

    def redis
      Redis.current
    end
  end
end
