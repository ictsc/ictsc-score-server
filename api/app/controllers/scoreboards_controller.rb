# 2日目の午後開始前まで確認可能
# - 自分の順位と得点
# - 上位3チームの得点とチーム名
# - 自分の1つ上のチームの得点
# - 各問題が何チームに解かれたか

class ScoreboardsController < ApplicationController
  before '/api/scoreboard*' do
    I18n.locale = :en if request.xhr?

    halt 400 if is_nologin?
    halt 400 if is_participant? && (!Config.in_competition_time? || Config.scoreboard_hide_at <= DateTime.now)
  end

  get '/api/scoreboard' do
    json Scoreboard.aggregate(current_user: current_user)
  end
end
