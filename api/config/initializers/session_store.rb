# frozen_string_literal: true

redis_url = URI.parse(ENV.fetch('REDIS_URL'))
server = {
  host: redis_url.host,
  port: redis_url.port,
  db: redis_url.path.sub(/^\//, ''),
  namespace: 'sessions'
}

Rails.application.config.session_store(:redis_store,
                                       servers: [server],
                                       expire_after: ENV.fetch('API_SESSION_EXPIRE_MINUTES').to_i.minutes,
                                       key: '_session',
                                       threadsafe: true)
