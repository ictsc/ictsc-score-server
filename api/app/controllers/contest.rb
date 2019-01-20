# 大会に関する情報を提供する
class ContestController < ApplicationController
  before '/api/contest*' do
    I18n.locale = :en if request.xhr?
  end

  get '/api/contest' do
    @contest_info = {
      answer_reply_delay_sec: Setting.answer_reply_delay_sec,
      competition_start_at: Setting.competition_start_at,
      scoreboard_hide_at: Setting.scoreboard_hide_at,
      competition_end_at: Setting.competition_end_at
    }
    json @contest_info
  end

  get '/api/contest/health' do
    status 200
    json status: 'success'
  end
end
