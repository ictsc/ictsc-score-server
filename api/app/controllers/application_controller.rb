# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :update_session_info

  private

  def logged_in?
    current_team.present?
  end

  def current_team
    session[:team_id].present? && Team.find_by(id: session[:team_id])
  end

  def require_login
    head :unauthorized unless logged_in?
  end

  def reject_audience
    head :forbidden if current_team.audience?
  end

  def update_session_info
    return if session[:team_id].blank?

    session[:latest_ip] = request.remote_ip
    session[:updated_at] = Time.current
  end
end
