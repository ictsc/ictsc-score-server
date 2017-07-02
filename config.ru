require 'bundler'
require 'fileutils'
require 'logger'
require 'securerandom'

Bundler.require

require_relative 'app.rb'

::Logger.class_eval { alias :write :<< unless respond_to?(:write) }

log_path = File.dirname(__FILE__) + '/log'
FileUtils.makedirs(log_path)
logger = Logger.new("#{log_path}/#{ENV['RACK_ENV']}.log", 'daily')

use Rack::LtsvLogger, logger
use Rack::PostBodyContentTypeParser

use Rack::Lineprof if ENV['RACK_ENV'] == 'development'

default_session_expire_sec = 60 * 60 * 24 * 7 # 1 week

if ENV['API_SESSION_USE_REDIS']
  use Rack::Session::Redis,
		redis_server: ENV.fetch('API_SESSION_REDIS_SERVER', 'redis://127.0.0.1:6379/0/rack:session'),
    expire_after: ENV.fetch('API_SESSION_EXPIRE_SEC', default_session_expire_sec).to_i
else
  use Rack::Session::Cookie,
    key: ENV.fetch('API_SESSION_COOKIE_KEY', 'rack.session'),
    secret: ENV.fetch('API_SESSION_COOKIE_SECRET') { SecureRandom.hex(64) },
    expire_after: ENV.fetch('API_SESSION_EXPIRE_SEC', default_session_expire_sec).to_i
end

run App
