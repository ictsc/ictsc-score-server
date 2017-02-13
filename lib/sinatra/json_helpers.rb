require "sinatra/base"
require "json"

module Sinatra
  module JSONHelpers
    def json(object, options = {})
      content_type :json, charset: "utf-8"
      object.to_json(options)
    end
  end

  helpers JSONHelpers
end
