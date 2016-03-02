require "bundler"

Bundler.require

settings.root = Dir.pwd

Bundler.require(settings.environment)

Dotenv.load

require_relative "app"
set :run, false
