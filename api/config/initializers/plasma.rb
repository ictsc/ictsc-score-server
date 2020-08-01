# frozen_string_literal: true

Rails.application.config.plasma_channels = ENV.fetch('PLASMA_SUBSCRIBER_REDIS_CHANNELS')
