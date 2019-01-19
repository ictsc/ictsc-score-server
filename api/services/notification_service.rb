require 'sinatra/base'
require 'redis'
require 'oj'
require_relative '../app/models/application_record'

Oj.mimic_JSON

module Sinatra
  module NotificationService
    # @params to: One of [Role, Team, Member]
    # @params payload: Hash
    def push_notification(to:, payload:)
      if to.respond_to? :each
        to.each {|t| push_notification(to: t, payload: payload) }
        return
      end

      return false unless pushable? to

      begin
        redis_client.publish(Setting.redis_realtime_notification_channel, publish_payload(to: to, payload: payload))
      rescue # rubocop:disable Style/RescueStandardError
        # Ignores error on pushing notification (because it's not critical)
        return false
      end

      true
    end

    private

    def pushable?(obj)
      return true if obj.is_a? String or obj.is_a? Symbol
      raise TypeError, "to don't have a notification_group" unless obj.respond_to? :notification_subscriber

      return true if obj.notification_subscriber

      # At this time, there's no subscriber because channel not exist.
      # For the next time, create subscriber
      obj.build_notification_subscriber
      obj.save
      false
    end

    def publish_payload(to:, payload:)
      channel_id =
        if to.is_a? String or to.is_a? Symbol
          to
        else
          to.notification_subscriber.channel_id
        end
      {
        data: payload.to_json,
        meta: {
          type: channel_id
        }
      }.to_json
    end

    def redis_client
      @redis_client ||= Redis.new
    end
  end

  helpers NotificationService
end
