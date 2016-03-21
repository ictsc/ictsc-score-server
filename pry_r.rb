require "bundler"

Bundler.require
Bundler.require(:development)

Dotenv.load

require_relative "app"

# settings.root = Dir.pwd

# set :run, false
