require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require "sinatra/config_file"
require_relative "../services/account_service"

# https://wiki.icttoracon.net/ictsc7/rules/public
# 2日目の午後開始前まで確認可能
# - 自分の順位と得点
# - 上位3チームの得点とチーム名
# - 自分の1つ上のチームの得点
# - 各問題が何チームに解かれたか

class ScoreBoardRoutes < Sinatra::Base
  register Sinatra::ConfigFile
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  config_file Pathname(settings.root).parent + "config/contest.yml"

  before "/api/scoreboard*" do
    I18n.locale = :en if request.xhr?
  end

  helpers do
    def scoreboard_for(team: nil, all: false)
      # [[1st_team_id, score], [2nd_team_id, score], [3rd_team_id, score], ...]
      all_scores = [
          Score.all.joins(:answer).group("answers.team_id").sum(:point),
          Score.firstbloods.joins(answer: { problem: {}}).group("answers.team_id").sum("problems.perfect_point").map{|tid, perfect_point| [tid, perfect_point * (settings.first_blood_bonus_percentage / 100.0)] },
          Score.cleared_problem_group_ids(with_tid: true).inject(Hash.new(0)){|acc, (tid, score_ids)| acc[tid] += score_ids.count * settings.bonus_point_for_clear_problem_group; acc },
        ] \
        .map(&:to_a) \
        .flatten(1) \
        .inject(Hash.new(0)){|acc, (team_id, score)| acc[team_id] += score; acc } \
        .to_a \
        .sort_by(&:last) \
        .reverse

      team_rank = all_scores.index{|(team_id, score)| team_id == team.id } if not all # beginning 0

      viewable_scores = all_scores.each_with_index.inject([]) do |acc, ((team_id, score), rank)|
        actual_rank = all_scores.index{|s| s[1] == score } + 1

        score_info = {
          score: score,
          rank: actual_rank
        }

        if all || actual_rank <= 3 || team_id == team&.id
          t = Team.find_by(id: team_id)
          score_info[:team] = t.as_json(only: [:id, :name, :organization])

          acc << score_info
        elsif (rank + 1) == team_rank
          acc << score_info
        end

        acc
      end
    end
  end

  get "/api/scoreboard" do
    case current_user&.role&.name
    when "Admin", "Writer", "Viewer"
      json scoreboard_for(all: true)
    when "Participant"
      halt 403 if settings.scoreboard_hide_at <= DateTime.now
      team = current_user.team
      halt 400 if team.nil?
      json scoreboard_for(team: team)
    else
      halt 400
    end
  end
end
