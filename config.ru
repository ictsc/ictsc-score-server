require "logger"
require "bundler"

require 'fileutils'
FileUtils.makedirs(["log"])

Bundler.require

require File.expand_path(File.dirname(__FILE__)) + '/app.rb'

log_path = File.dirname(__FILE__) + "/log"
FileUtils.makedirs(log_path)
logger = Logger.new("#{log_path}/#{ENV["RACK_ENV"]}.log", "daily")
logger.instance_eval { alias :write :<< unless respond_to?(:write) }

use Rack::CommonLogger, logger
use Rack::PostBodyContentTypeParser

use Rack::Session::Redis, expire_after: 60 * 60 * 24 * 7 # 1 week
# use Rack::Session::Pool,
# use Rack::Session::Cookie,
  # key: "rack.session",
  # secret: "change_me",
  # expire_after: 60 * 60 * 24 * 7 # 1 week

run App
