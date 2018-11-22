require "sinatra/activerecord_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"

class ProblemGroupRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers
end
