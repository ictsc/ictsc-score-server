require 'sinatra/competition_helpers'

# 2日目の午後開始前まで確認可能
# - 自分の順位と得点
# - 上位3チームの得点とチーム名
# - 自分の1つ上のチームの得点
# - 各問題が何チームに解かれたか

class ScoreboardController < ApplicationController
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

  def scoreboard_for(all: false) # rubocop:disable Metrics/MethodLength
    # [{1st_team, score, rank}, {2nd_team, score, rank}, {3rd_team, score, rank}, ...]
    scores = Scoreboard.new(user: current_user)

    # -1: may happen when team has nothing score yet
    my_team_rank = scores.find_by_team(current_user.team)&.fetch(:rank) || -1 unless all

    viewable_config = Setting.scoreboard_viewable_config

    scores.map do |current|
      # 表示する情報を決める
      display_mode =
        if all || current[:team] == current_user.team
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
        score_info[:team] = current[:team].as_json(only: %i[id name organization])
      end

      if viewable_config[display_mode][:score]
        score_info[:score] = current[:score]
      end

      score_info
    end
      .compact
  end

  get '/api/scoreboard' do
    if is_staff?
      json scoreboard_for(all: true)
    elsif is_participant?
      json scoreboard_for
    end
  end
end
