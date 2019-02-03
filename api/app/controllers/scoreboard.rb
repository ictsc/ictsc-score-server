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
    json scoreboard_for
  end

  private

  def scoreboard_for
    # [{1st_team, score, rank}, {2nd_team, score, rank}, {3rd_team, score, rank}, ...]
    scores = Scoreboard.new(user: current_user)

    # when team has nothing score, this value is nil
    my_team_rank = scores.find_by_team(current_user.team)&.fetch(:rank) unless current_user.staff?

    scores.map do |score|
      display_mode = select_display_mode(current_user, scores, score, my_team_rank)
      next unless display_mode

      build_score_info(score, display_mode)
    end
      .compact
  end

  def select_display_mode(current_user, scores, score, my_team_rank)
    if current_user.staff? || score[:team] == current_user.team
      :all
    elsif score[:rank] <= Setting.scoreboard_viewable_top
      :top
    elsif (score[:rank] + scores.count_same_rank(score[:rank])) == my_team_rank
      # 1ランク上のチーム全て
      :up
    else
      # 表示しない
      nil
    end
  end

  def build_score_info(score, display_mode)
    score_info = { rank: score[:rank] }

    if Setting.scoreboard_viewable_config[display_mode][:team]
      score_info[:team] = score[:team].as_json(only: %i[id name organization])
    end

    if Setting.scoreboard_viewable_config[display_mode][:score]
      score_info[:score] = score[:score]
    end

    score_info
  end
end
