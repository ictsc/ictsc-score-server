#!/usr/bin/env ruby
# Coding: UTF-8

Dotenv.load
Bundler.require(ENV["RACK_ENV"]) if ENV["RACK_ENV"]

$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))

require_relative "controllers/answer"
require_relative "controllers/attachment"
require_relative "controllers/comment"
require_relative "controllers/issue"
require_relative "controllers/member"
require_relative "controllers/notification"
require_relative "controllers/notice"
require_relative "controllers/problem"
require_relative "controllers/problem_group"
require_relative "controllers/score"
require_relative "controllers/scoreboard"
require_relative "controllers/team"
require_relative "controllers/contest"
require_relative "controllers/asset"

require_relative "db/model"

class App < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  error_logger = ::File.new("#{File.dirname(__FILE__)}/log/#{ENV["RACK_ENV"]}-error.log", "a+")
  error_logger.sync = true

  use AnswerRoutes
  use AttachmentRoutes
  use CommentRoutes
  use IssueRoutes
  use MemberRoutes
  use NotificationRoutes
  use NoticeRoutes
  use ProblemRoutes
  use ProblemGroupRoutes
  use ScoreRoutes
  use ScoreBoardRoutes
  use TeamRoutes
  use ContestRoutes
  use AssetRoutes

  if defined? BetterErrors
    [self, *Sinatra::Base.descendants].each do |klass|
      klass.class_eval do
        configure :development do
          use BetterErrors::Middleware
          BetterErrors.application_root = settings.root
          BetterErrors::Middleware.allow_ip! "0.0.0.0/0"
        end
      end
    end
  end

  configure do
    Time.zone = "Tokyo"
    ActiveRecord::Base.default_timezone = :local

    if defined? Activerecord::Mysql::Reconnect
      ActiveRecord::Base.enable_retry = true
      ActiveRecord::Base.execution_tries = 3
    end
    # set :cometio, timeout: 120, post_interval: 2, allow_crossdomain: false
    # set :websocketio, port: 9000
    # set :rocketio, websocket: true, comet: true # enable WebSocket and Comet

    enable :prefixed_redirects
    set :haml, { escape_html: false, format: :html5 }
    set :scss, style: :expanded

    # I18n.enforce_available_locales = false
    I18n.load_path = Dir[File.join(settings.root, "locales", "*.yml")]
    I18n.backend.load_translations
    I18n.locale = :ja
  end

  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end

  end

  options "*" do
    response.headers["Allow"] =  "HEAD,GET,PUT,PATCH,POST,DELETE,OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Accept, Authorization, Cache-Control, Content-Type"
    response.headers["Access-Control-Expose-Headers"] = "X-Requested-With, X-HTTP-Method-Override, X-From"
    response.headers["Access-Control-Allow-Credentials"] = "true"

    200
  end

  before do
    env["rack.errors"] = error_logger
  end

  not_found do
    if request.xhr?
      { error: "not found" }.to_json
    else
      "<h1>Not Found</h1>"
    end
  end
end
