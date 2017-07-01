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
  
  config.before :suite do
    DatabaseCleaner.clean_with :truncation
  end

  config.before :each do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end
 
  config.after :each do
    DatabaseCleaner.clean
  end
end

def app
  App
end
