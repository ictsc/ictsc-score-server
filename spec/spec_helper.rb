require "bundler"
Bundler.require
Bundler.require(:test)

require "rspec"
require "rack/test"
# require "minitest/autorun"

RSpec.configure do |config|
  config.color = true
  config.tty = true
end
