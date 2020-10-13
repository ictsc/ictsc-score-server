# frozen_string_literal: true

Rails.application.configure do
  next if Rails.env.production?

  config.after_initialize do
    # graphql-batchを使っていてもN+1をご検知するため無効にする
    Bullet.enable = false
    Bullet.raise = false
    Bullet.rails_logger = true
    Bullet.bullet_logger = true

    Bullet.bugsnag = false
    Bullet.console = false
    Bullet.alert = false
    Bullet.growl = false
    Bullet.honeybadger = false
    Bullet.airbrake = false
    Bullet.rollbar = false
    Bullet.add_footer = false
    Bullet.skip_html_injection = false

    # Bullet.slack = { webhook_url: 'http://some.slack.url', channel: '#default', username: 'notifier' }
    # Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
    # Bullet.stacktrace_excludes = [ 'their_gem', 'their_middleware', ['my_file.rb', 'my_method'], ['my_file.rb', 16..20] ]
  end
end
