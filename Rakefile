require "bundler"

Bundler.require
Bundler.require(ENV["RACK_ENV"]) if ENV["RACK_ENV"]

require "sinatra/activerecord/rake"

namespace :db do
  task :load_config do
    require_relative "app"
  end
end
