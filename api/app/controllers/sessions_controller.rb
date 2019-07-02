# frozen_string_literal: true

class SessionsController < ApplicationController
  def current
    if logged_in?
      team = Team.find_by(id: session[:team_id])
      render json: build_current_team_response(team), status: :ok
    else
      head :unauthorized
    end
  end

  def login
    team = Team.login(name: login_params[:name], password: login_params[:password])

    if team
      reset_session
      session[:team_id] = team.id
      render json: build_current_team_response(team), status: :ok
    else
      head :bad_request
    end
  end

  def logout
    if logged_in?
      reset_session
      head :ok
    else
      head :unauthorized
    end
  end

  private

  def login_params
    params.permit(:name, :password)
  end

  def logged_in?
    Team.exists?(id: session[:team_id])
  end

  # 必要な値だけ返す
  def build_current_team_response(team)
    { id: team.id, role: team.role }
  end
end
