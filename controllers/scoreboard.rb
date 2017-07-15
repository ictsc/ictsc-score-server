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
      # [[1st_team_id, score], [2nd_team_id, score], [3rd_team_id, score], ...]
      all_scores = [
          Score.all.joins(:answer).group("answers.team_id").sum(:point),
          Score.firstbloods.joins(answer: { problem: {}}).group("answers.team_id").sum("problems.perfect_point").map{|tid, perfect_point| [tid, perfect_point * (Setting.first_blood_bonus_percentage / 100.0)] },
          Score.cleared_problem_group_ids(with_tid: true).inject(Hash.new(0)){|acc, (tid, score_ids)| acc[tid] += score_ids.count * Setting.bonus_point_for_clear_problem_group; acc },
        ] \
        .map(&:to_a) \
        .flatten(1) \
        .inject(Hash.new(0)){|acc, (team_id, score)| acc[team_id] += score; acc } \
        .to_a \
        .sort_by(&:last) \
        .reverse

      if not all
        team_score = all_scores.find{|(team_id, score)| team_id == team.id }&.last
        team_actual_rank = if team_score
            all_scores.index{|(team_id, score)| team_score == score } + 1
          else
            -1 # may happen when team has nothing score yet
          end
      end

      viewable_scores = all_scores.each_with_index.inject([]) do |acc, ((team_id, team_score), rank)|
        actual_rank = all_scores.index{|(team_id, score)| team_score == score } + 1
        same_actual_rank_teams_count = all_scores.map(&:last).count(team_score)

        score_info = {
          score: team_score,
          rank: actual_rank
        }

        if all || actual_rank <= 3 || team_id == team&.id
          t = Team.find_by(id: team_id)
          score_info[:team] = t.as_json(only: [:id, :name, :organization])

          acc << score_info
        elsif (actual_rank + same_actual_rank_teams_count) == team_actual_rank
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
      halt 400 if Setting.scoreboard_hide_at <= DateTime.now
      team = current_user.team
      halt 400 if team.nil?
      json scoreboard_for(team: team)
    else
      halt 400
    end
  end
end
