# frozen_string_literal: true

class Session
  PREFIX = 'sessions:'
  FIELDS = %i[id team_id latest_ip created_at updated_at].freeze
  Record = Struct.new(*FIELDS, keyword_init: true)

  class << self
    def keys
      redis.keys("#{PREFIX}*")
    end

    def all
      keys
        .map {|key| get(key) }
        .compact
    end

    def find(id)
      get(id_to_key(id))
    end

    def find_by(id:)
      get(id_to_key(id))
    end

    def where(team_id:)
      all.select {|session| session[:team_id] == team_id }
    end

    def destroy_all
      redis.del(keys)
    end

    def destroy(id)
      redis.del(id_to_key(id))
    end

    def destroy_by(team_id:)
      keys = where(team_id: team_id)
        .map {|record| id_to_key(record.id) }

      redis.del(keys) if keys.present?
    end

    # 存在しないteam_idを持つレコードを消す
    def prune
      Session
        .all
        .select {|s| Team.find_by(id: s.team_id).nil? }
        .each {|s| Session.destroy(s.id) }
    end

    private

    # idをredisのキーに変換する
    def id_to_key(id)
      "#{PREFIX}#{id}"
    end

    def get(key)
      raw_value = redis.get(key)
      return nil unless raw_value

      value = Marshal.load(raw_value) # rubocop:disable Security/MarshalLoad
      # ログアウトさせられたユーザーがその状態でアクセスすると{}が登録される
      return nil if value.blank?

      Record.new(
        id: key.delete_prefix(PREFIX),
        **value.slice(*%w[team_id latest_ip created_at updated_at])
      )
    end

    def redis
      Redis.current
    end
  end
end
