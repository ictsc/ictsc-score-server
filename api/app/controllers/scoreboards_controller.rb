class ScoreboardsController < ApplicationController
  before_action :set_scoreboard, only: [:show, :update, :destroy]

  # GET /scoreboards
  def index
    @scoreboards = Scoreboard.all

    render json: @scoreboards
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
    # Use callbacks to share common setup or constraints between actions.
    def set_scoreboard
      @scoreboard = Scoreboard.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def scoreboard_params
      params.fetch(:scoreboard, {})
    end
end
