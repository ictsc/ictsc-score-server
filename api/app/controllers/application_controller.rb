require 'sinatra/activerecord_helpers'
require 'sinatra/json_helpers'
require_relative '../../services/account_service'
require_relative '../../services/nested_entity'
require_relative '../../services/notification_service'

class ApplicationController < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    %w[app lib services].each {|dir| also_reload File.join(dir, '**', '*.rb') }
  end

  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers
  helpers Sinatra::NotificationService
end

require_relative 'answers_controller'
require_relative 'attachments_controller'
require_relative 'comments_controller'
require_relative 'configs_controller'
require_relative 'contests_controller'
require_relative 'issues_controller'
require_relative 'members_controller'
require_relative 'notices_controller'
require_relative 'notifications_controller'
require_relative 'problem_groups_controller'
require_relative 'problems_controller'
require_relative 'scoreboards_controller'
require_relative 'scores_controller'
require_relative 'sessions_controller'
require_relative 'teams_controller'
