class ContestsController < ApplicationController
  before_action :set_contest, only: [:show, :update, :destroy]

  # GET /contests
  def index
    @contest_info = {
      answer_reply_delay_sec: Setting.answer_reply_delay_sec,
      competition_start_at: Setting.competition_start_at,
      scoreboard_hide_at: Setting.scoreboard_hide_at,
      competition_end_at: Setting.competition_end_at
    }
    json @contest_info
    @contests = Contest.all

    render json: @contests
  end

  # get '/api/contest/health' do
  #   render json: {status: 'success'}, status: :success
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contest
      @contest = Contest.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def contest_params
      params.fetch(:contest, {})
    end
end
