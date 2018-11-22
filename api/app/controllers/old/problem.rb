require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require "sinatra/competition_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"

class ProblemRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers
  helpers Sinatra::CompetitionHelpers
end
