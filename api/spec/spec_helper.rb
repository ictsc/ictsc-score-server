ENV['RACK_ENV'] = 'test'
ENV['RAILS_ENV'] ='test'

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
    DatabaseCleaner.strategy = :transaction

    ApiHelpers.current_users = {
      admin: FactoryBot.create(:member, :admin),
      writer: FactoryBot.create(:member, :writer),
      viewer: FactoryBot.create(:member, :viewer),
      participant: FactoryBot.create(:member, :participant),
      nologin: nil
    }
  end

  config.after :suite do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.clean
  end

  config.around :each do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

def app
  App
end
