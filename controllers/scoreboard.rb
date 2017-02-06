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
      # [[team_id, 1st_score], [team_id, 2nd_score], [team_id, 3rd_score], ...]
      all_scores = Score.all.joins(:answer).group("answers.team_id").sum(:point).to_a.sort_by(&:last).reverse
      team_rank = all_scores.index{|(team_id, score)| team_id == team.id } if not all # beginning 0

      viewable_scores = all_scores.map.with_index do |(team_id, score), i|
        if all || i < 3 || team_id == team.id || (i + 1) == team_rank
          score_info = { score: score, rank: i+1 }
          if all || i < 3 || team_id == team.id
            t = Team.find_by(id: team_id)
            next score_info.merge(id: t.id, name: t.name)
          else
            # 参加者 かつ 自分の1つ上のチームの場合は、チーム名に関する情報を含まない
            next score_info
          end
        else
          nil
        end
      end.compact
    end
  end

  get "/api/scoreboard" do
    case true
    when is_admin?, is_writer?, is_viewer?
      json scoreboard_for(all: true)
    when is_participant?
      team = current_user.team
      halt 400 if team.nil?
      json scoreboard_for(team: team)
    else
      halt 400
    end
  end

  get "/api/scoreboard/as/:team_id" do
    team = Team.find_by(id: params[:team_id])
    halt 404 if team.nil?

    json scoreboard_for(team: team)

    # @scores = Score.accessible_resources(user_and_method)
    # json @scores
  end
end
