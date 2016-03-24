require 'rspec'
require 'rack/test'
require 'minitest/autorun'

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  config.color = true
  config.tty = true
end
