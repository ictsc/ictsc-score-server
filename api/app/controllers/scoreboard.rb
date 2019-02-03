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

  get '/api/scoreboard' do
    json Scoreboard.aggregate(current_user: current_user)
  end
end
