require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require "sinatra/crypt_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"

class TeamRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers
  helpers Sinatra::CryptHelpers
end
