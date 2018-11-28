# require_relative "../db/model"

module AccountHelpers
  module_function

  def require_login(*block)
    halt 401 unless logged_in?
  end

  def logged_in?
    return false if session[:member_id].nil?
    @logged_in ||= Member.exists?(id: session[:member_id])
  end

  def current_user
    return nil if not logged_in?
    @current_user ||= Member.includes(:role).find_by(id: session[:member_id])
  end

  def login_as(member_id)
    raise if not Member.exists?(id: member_id)
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

  def is_admin?
    return current_user&.role&.id == ROLE_ID[:admin]
  end

  def is_viewer?
    return current_user&.role&.id == ROLE_ID[:viewer]
  end

  def is_participant?
    return current_user&.role&.id == ROLE_ID[:participant]
  end

  def is_writer?
    return current_user&.role&.id == ROLE_ID[:writer]
  end

  def is_nologin?
    return current_user.nil? || current_user&.role&.id == ROLE_ID[:nologin]
  end

  def is_staff?
    return is_admin? || is_writer? || is_viewer?
  end
end
