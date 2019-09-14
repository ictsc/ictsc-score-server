# frozen_string_literal: true

class ApplicationController < ActionController::API
  private

  def logged_in?
    Team.exists?(id: session[:team_id])
  end

  def current_team
    Team.find_by(id: session[:team_id])
  end

  def require_login
    return if logged_in?

    head :unauthorized
  end
end
