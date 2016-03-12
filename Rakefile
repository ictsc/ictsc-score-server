require "bundler"

Bundler.require
Bundler.require(settings.environment)
require "sinatra/activerecord/rake"

namespace :db do
  task :load_config do
    require_relative "app"
  end
end
