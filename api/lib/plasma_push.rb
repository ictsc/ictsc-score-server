# frozen_string_literal: true

# PlasmaでSSEを使うための汎用的なクラス
class PlasmaPush
  class << self
    # to: scalar or array of Team, :everyone, :staff, :player or :audience
    # data: send data
    def push(to:, data:)
      build_channel_ids(to: to).each do |channel_id|
        publish(channel_id: channel_id, data: data)
      end
    end

    private

    def redis
      Redis.current
    end

    def publish(channel_id:, data:)
      payload = build_payload(channel_id: channel_id, data: data)
      redis.publish(Rails.application.config.plasma_channels, payload)
    end

    def build_channel_ids(to:)
      # 配列対応
      return to.flat_map {|t| build_channel_ids(to: t) } if to.respond_to?(:each)

      # Team
      return [to.channel] if to.respond_to?(:channel)

      case to.to_sym
      when :everyone, :player
        # 数が多いので専用チャンネルがある
        [to.to_s]
      when :staff, :audience
        Team.public_send(to).pluck(:channel)
      else
        raise UnhandledNotificationTarget, to
      end
    end

    def build_payload(channel_id:, data:)
      {
        meta: {
          # UI側のeventTypeで指定して対象を絞れる
          type: channel_id
        },
        data: data
      }.to_json
    end
  end
end
