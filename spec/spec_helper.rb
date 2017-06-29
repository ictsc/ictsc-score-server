require 'bundler'
Bundler.require
Bundler.require(:test)

require 'rspec'
require 'rack/test'
require_relative 'support/factory_girl'
require_relative 'support/api_helpers'
require_relative '../app'

RSpec.configure do |config|
  config.color = true
  config.tty = true

  config.include Rack::Test::Methods
  
  DatabaseCleaner.strategy = :truncation, {:except => %w[roles]}

  config.before :each do
    DatabaseCleaner.start
  end
 
  config.after :each do
    DatabaseCleaner.clean
  end

  config.before :suite do
    SeedFu.seed
  end
end

def app
  App
end
