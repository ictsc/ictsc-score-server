require 'bundler'
Bundler.require
Bundler.require(:test)

SimpleCov.start do
  add_filter "/spec/"
end

require_relative 'support/factory_bot'
require_relative 'support/api_helpers'
require_relative '../app'

RSpec.configure do |config|
  config.color = true
  config.tty = true

  config.include Rack::Test::Methods
  
  # Disable verbose default logger
  ActiveRecord::Base.logger = nil

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
