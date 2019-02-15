# 大会に関する情報を提供する
class ContestController < ApplicationController
  before '/api/contest*' do
    I18n.locale = :en if request.xhr?
  end

  get '/api/contest' do
    # TODO: key修正
    @contest_info = {
      answer_reply_delay_sec: Config.grading_delay_sec,
      scoreboard_hide_at: Config.scoreboard_hide_at,
      competition_start_at: Config.competition_start_at,
      competition_end_at: Config.competition_end_at
    }
    json @contest_info
  end

  get '/api/contest/health' do
    status 200
    json status: 'success'
  end
end
