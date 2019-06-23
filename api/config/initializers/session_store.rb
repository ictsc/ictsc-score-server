# frozen_string_literal: true

Rails.application.config.session_store(:redis_store,
                                       servers: [ENV.fetch('REDIS_URL')],
                                       # expire_after: 90.minutes,
                                       key: '_session',
                                       threadsafe: false)
