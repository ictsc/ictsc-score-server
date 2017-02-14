require "sinatra/json_helpers"
require "sinatra/config_file"

# 大会に関する情報を提供する

class ContestRoutes < Sinatra::Base
	register Sinatra::ConfigFile
	helpers Sinatra::JSONHelpers

	config_file Pathname(settings.root).parent + "config.yml"

  before "/api/scoreboard*" do
    I18n.locale = :en if request.xhr?
  end

  get "/api/contest" do
  	@contest_info = {
  	  answer_reply_delay_sec: settings.answer_reply_delay_sec,
  	  first_blood_bonus_percentage: settings.first_blood_bonus_percentage,
  	  competition_start_time: settings.competition_start_time,
  	  scoreboard_hide_at: settings.scoreboard_hide_at,
  	  competition_end_time: settings.competition_end_time
  	}
  	json @contest_info
  end
end

