require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

# https://wiki.icttoracon.net/ictsc7/rules/public
# 2日目の午後開始前まで確認可能
# - 自分の順位と得点
# - 上位3チームの得点とチーム名
# - 自分の1つ上のチームの得点
# - 各問題が何チームに解かれたか

class ScoreBoardRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/api/scoreboard*" do
    I18n.locale = :en if request.xhr?
  end

  helpers do
    def scoreboard_for(team: nil, all: false)
      # [[1st_team_id, score, rank], [2nd_team_id, score, rank], [3rd_team_id, score, rank], ...]
      scores = Score::Scores.new

      # -1: may happen when team has nothing score yet
      my_team_rank = scores.find(team.id)&.at(2) || -1 unless all

      viewable_scores = scores.all_scores.inject([]) do |acc, (team_id, team_score, team_rank)|
        same_rank_teams_count = scores.all_scores.count{|(id, score, rank)| rank == team_rank }

        score_info = {
          score: team_score,
          rank: team_rank
        }

        if all || team_rank <= Setting.scoreboard_viewable_top || team_id == team&.id
          t = Team.find_by(id: team_id)
          score_info[:team] = t.as_json(only: [:id, :name, :organization])

          acc << score_info
        elsif (team_rank + same_rank_teams_count) == my_team_rank
          acc << score_info
        end

        acc
      end

      viewable_scores
    end
  end

  get "/api/scoreboard" do
    case current_user&.role&.name
    when "Admin", "Writer", "Viewer"
      json scoreboard_for(all: true)
    when "Participant"
      halt 400 if Setting.scoreboard_hide_at <= DateTime.now
      team = current_user.team
      halt 400 if team.nil?
      json scoreboard_for(team: team)
    else
      halt 400
    end
  end
end
