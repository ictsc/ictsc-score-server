require 'sinatra/base'
require_relative '../app/models/application_record'

module Sinatra
  module AccountServiceHelpers
    def require_login(*block)
      halt 401 unless logged_in?
    end

    def logged_in?
      return false if session[:member_id].nil?

      @logged_in ||= Member.exists?(id: session[:member_id])
    end

    def current_user
      return nil unless logged_in?

      @current_user ||= Member.includes(:role).find_by(id: session[:member_id])
    end

    def login_as(member_id)
      raise unless Member.exists?(id: member_id)

      session[:member_id] = member_id
    end

    def logout
      session.delete(:member_id)
      @logged_in = nil
      @current_user = nil
    end

    def user_and_method
      return {
        user: current_user,
        method: request.request_method
      }
    end

    # rubocop:disable Naming/PredicateName
    def is_admin?
      current_user&.admin?
    end

    def is_viewer?
      current_user&.viewer?
    end

    def is_participant?
      current_user&.participant?
    end

    def is_writer?
      current_user&.writer?
    end

    def is_nologin?
      current_user.nil? || current_user&.nologin?
    end

    def is_staff?
      current_user&.staff?
    end
    # rubocop:enable Naming/PredicateName
  end

  helpers AccountServiceHelpers
end
