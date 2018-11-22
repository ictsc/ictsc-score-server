class ScoreboardsController < ApplicationController
  before_action :before_all
  before_action :set_scoreboard, only: [:show, :update, :destroy]

  # GET /scoreboards
  def index
    if is_staff?
      render json: scoreboard_for(all: true)
    elsif is_participant?
      team = current_user.team
      render status: :bad_requst and return if team.nil?
      render json: scoreboard_for(team: team)
    end
  end

  # GET /scoreboards/1
  def show
    render json: @scoreboard
  end

  # POST /scoreboards
  def create
    @scoreboard = Scoreboard.new(scoreboard_params)

    if @scoreboard.save
      render json: @scoreboard, status: :created, location: @scoreboard
    else
      render json: @scoreboard.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /scoreboards/1
  def update
    if @scoreboard.update(scoreboard_params)
      render json: @scoreboard
    else
      render json: @scoreboard.errors, status: :unprocessable_entity
    end
  end

  # DELETE /scoreboards/1
  def destroy
    @scoreboard.destroy
  end

  private
    def before_all
      I18n.locale = :en if request.xhr?

      # アクセス禁止処理
      halt 400 if is_nologin?

      if is_participant?
        if !in_competition? || Setting.scoreboard_hide_at <= DateTime.now
          halt 400
        end
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_scoreboard
      @scoreboard = Scoreboard.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def scoreboard_params
      params.fetch(:scoreboard, {})
    end

    def scoreboard_for(team: nil, all: false)
      # [{1st_team_id, score, rank}, {2nd_team_id, score, rank}, {3rd_team_id, score, rank}, ...]
      scores = Score::Scores.new(user: current_user)

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
          score_info[:team] = t.as_json(only: [:id, :name, :organization])
        end

        if viewable_config[display_mode][:score]
          score_info[:score] = current[:score]
        end

        acc << score_info
      end

      viewable_scores
    end
end
