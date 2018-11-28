class ApplicationController < ActionController::API
  # TODO: 移行が終わったらconcernsにしたりする
  include AccountHelpers
  include AttributeHelpers
  include CompetitionHelpers
  include Crypt
  include JSONHelpers
  include NestedEntityHelpers
  include NotificationHelpers

  extend AccountHelpers
  extend AttributeHelpers
  extend CompetitionHelpers
  extend Crypt
  extend JSONHelpers
  extend NestedEntityHelpers
  extend NotificationHelpers
end
