# frozen_string_literal: true

class SessionsController < ApplicationController
  def valid?
    # セッションが有効化調べる
    head logged_in? ? :ok : :unauthorized
  end

  def login
    team = Team.login(name: login_params[:name], password: login_params[:password])

    if team
      reset_session
      session[:team_id] = team.id
      # 必要な値だけ返す
      render json: { id: team.id, role: team.role }, status: :ok
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
end
