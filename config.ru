require "logger"
require "bundler"

require 'fileutils'
FileUtils.makedirs(["log"])


Bundler.require

set :environment, :development
# set :environment, :production

Bundler.require(settings.environment)

Dotenv.load

require File.expand_path(File.dirname(__FILE__)) + '/app.rb'

use Rack::Session::Pool,
  key: 'sessionkey',
  secret: 'secret',
  path: '/',
  expire_after: 60 * 60 * 24 * 7 # 1 week

use Rack::Protection
run Sinatra::Application
