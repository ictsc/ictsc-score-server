# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    team = Team.login(name: login_params[:name], password: login_params[:password])

    if team
      reset_session
      session[:team_id] = team.id
      head :ok
    else
      head :bad_request
    end
  end

  def destroy
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
