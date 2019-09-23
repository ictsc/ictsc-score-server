# frozen_string_literal: true

class ApplicationController < ActionController::API
  thread_cattr_accessor :logger_paylod

  before_action :setup_logger_payload

  private

  def setup_logger_payload
    Rails.logger.debug ApplicationController.new

  end

  def logged_in?
    current_team.present?
  end

  def current_team
    session[:team_id].present? && Team.find_by(id: session[:team_id])
  end

  def require_login
    return if logged_in?

    head :unauthorized
  end
end
