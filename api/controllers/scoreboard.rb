require 'sinatra/activerecord_helpers'
require 'sinatra/json_helpers'
require 'sinatra/competition_helpers'
require_relative '../services/account_service'

# 2日目の午後開始前まで確認可能
# - 自分の順位と得点
# - 上位3チームの得点とチーム名
# - 自分の1つ上のチームの得点
# - 各問題が何チームに解かれたか

class ScoreBoardRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers
  helpers Sinatra::CompetitionHelpers

  before '/api/scoreboard*' do
    I18n.locale = :en if request.xhr?

    # アクセス禁止処理
    halt 400 if is_nologin?

    if is_participant?
      if !in_competition? || Setting.scoreboard_hide_at <= DateTime.now
        halt 400
      end
    end
  end

  def scoreboard_for(team: nil, all: false) # rubocop:disable Metrics/MethodLength
    # [{1st_team_id, score, rank}, {2nd_team_id, score, rank}, {3rd_team_id, score, rank}, ...]
    scores = ScoreAggregater.new(user: current_user)

    # -1: may happen when team has nothing score yet
    my_team_rank = scores.find_by_id(team.id)&.fetch(:rank) || -1 unless all

    viewable_config = Setting.scoreboard_viewable_config

    viewable_scores = scores.each_with_object([]) do |current, acc|
      # 表示する情報を決める
      display_mode =
        if all || current[:team_id] == team&.id
          :all
        elsif current[:rank] <= Setting.scoreboard_viewable_top
          :top
        elsif (current[:rank] + scores.count_same_rank(current[:rank])) == my_team_rank
          # 1ランク上のチーム全て
          :up
        else
          # 表示しない
          nil
        end

      next unless display_mode

      score_info = {
        rank: current[:rank],
      }

      if viewable_config[display_mode][:team]
        t = Team.find_by(id: current[:team_id])
        score_info[:team] = t.as_json(only: %i[id name organization])
      end

      if viewable_config[display_mode][:score]
        score_info[:score] = current[:score]
      end

      acc << score_info
    end

    viewable_scores
  end

  get '/api/scoreboard' do
    if is_staff?
      json scoreboard_for(all: true)
    elsif is_participant?
      team = current_user.team
      halt 400 if team.nil?
      json scoreboard_for(team: team)
    end
  end
end
