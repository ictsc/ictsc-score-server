require "sinatra/base"
require "oj"

Oj.default_options = { mode: :compat, nan: :huge }

module Sinatra
  module JSONHelpers
    def json(object, options = {})
      content_type :json, charset: "utf-8"
      case object
      when ActiveRecord::Base, ActiveRecord::Relation
        json = object.as_json(options)
        Oj.dump(json)
      else
        Oj.dump(object)
      end
    end
  end

  helpers JSONHelpers
end
