# frozen_string_literal: true

redis_url = URI.parse(ENV.fetch('REDIS_URL'))
server = {
  host: redis_url.host,
  port: redis_url.port,
  db: redis_url.path.sub(%r{^/}, ''),
  namespace: 'sessions'
}

Rails.application.configure do
  # https://github.com/redis-store/redis-actionpack
  # secure 有効にすると本番環境ではHTTPS必須になる
  config.session_store(
    :redis_store,
    servers: [server],
    expire_after: ENV.fetch('API_SESSION_EXPIRE_MINUTES').to_i.minutes,
    key: '_session',
    # secure: Rails.env.production?,
    threadsafe: false
  )

  # ここで有効にしないとkeyなどの設定が反映されない
  config.middleware.use ActionDispatch::Cookies # Required for all session management (regardless of session_store)
  config.middleware.use config.session_store, config.session_options
end
