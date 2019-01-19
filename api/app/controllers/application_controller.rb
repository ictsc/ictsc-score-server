require 'sinatra/activerecord_helpers'
require 'sinatra/json_helpers'
require_relative '../../services/account_service'
require_relative '../../services/nested_entity'
require_relative '../../services/notification_service'

class ApplicationController < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers
  helpers Sinatra::NotificationService
end

require_relative 'answer'
require_relative 'attachment'
require_relative 'comment'
require_relative 'issue'
require_relative 'member'
require_relative 'notification'
require_relative 'notice'
require_relative 'problem'
require_relative 'problem_group'
require_relative 'score'
require_relative 'scoreboard'
require_relative 'team'
require_relative 'contest'
