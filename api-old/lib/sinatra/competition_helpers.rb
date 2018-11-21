require 'sinatra/base'

module Sinatra
  module CompetitionHelpers
    def in_competition?
      now = DateTime.now
      Setting.competition_start_at <= now && now < Setting.competition_end_at
    end
  end

  helpers CompetitionHelpers
end
