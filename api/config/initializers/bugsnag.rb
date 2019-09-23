# frozen_string_literal: true

# Docs. https://docs.bugsnag.com/platforms/ruby/rails/configuration-options/
# 補足されなかった例外はbugsnagに通知される
Bugsnag.configure do |config|
  config.api_key = ENV['BUGSNAG_API_KEY']

  # RACK_ENVを送信する(ENV全てを送るわけではない)
  # cookieなどはデフォルトでフィルタされている
  config.send_environment = true
end
