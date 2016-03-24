require "bundler"
Bundler.require
Bundler.require(:test)

require "rspec"
require "rack/test"
require_relative "../app"

RSpec.configure do |config|
  config.color = true
  config.tty = true

  config.include Rack::Test::Methods

  config.after :suite do
    ActiveRecord::Base.subclasses.each(&:delete_all)
  end
end

def app
  App
end
