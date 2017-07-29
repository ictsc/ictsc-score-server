require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"
require_relative "../services/notification_service"

class NoticeRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers
  helpers Sinatra::NotificationService

  before "/api/notices*" do
    I18n.locale = :en if request.xhr?

    @with_param = (params[:with] || "").split(?,) & %w(member) if request.get?
  end

  get "/api/notices" do
    @notices = generate_nested_hash(klass: Notice, by: current_user, params: @with_param, apply_filter: !(is_admin? || is_viewer?))
    @notices.map do |n|
      n["member"]&.delete("hashed_password")
    end
    json @notices
  end

  before "/api/notices/:id" do
    @notice = Notice.find_by(id: params[:id])
    halt 404 if not @notice&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/notices/:id" do
    @notice = generate_nested_hash(klass: Notice, by: current_user, params: @with_param, id: params[:id].to_i, apply_filter: !(is_admin? || is_viewer?))
    @notice["member"]&.delete("hashed_password")
    json @notice
  end

  post "/api/notices" do
    halt 403 if not Notice.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Notice)
    @attrs[:member_id] = current_user.id if (not is_admin?) || @attrs[:member_id].nil?
    @notice = Notice.new(@attrs)

    if @notice.save
      status 201
      headers "Location" => to("/api/notices/#{@notice.id}")
      push_notification(to: :everyone, payload: @notice.notification_payload)
      json @notice
    else
      status 400
      json @notice.errors
    end
  end

  update_notice_block = Proc.new do
    if request.put? and not filled_all_attributes_of?(klass: Notice)
      status 400
      next json required: insufficient_attribute_names_of(klass: Notice)
    end

    @attrs = params_to_attributes_of(klass: Notice)

    if (not is_admin?) && @attrs[:member_id] != nil && @attrs[:member_id].to_i != current_user&.id
      status 400
      next json member_id: "can't set to other member"
    end

    @notice.attributes = @attrs

    if not @notice.valid?
      status 400
      next json @notice.errors
    end

    if @notice.save
      push_notification(to: :everyone, payload: @notice.notification_payload(state: :updated))
      json @notice
    else
      status 400
      json @notice.errors
    end
  end

  put "/api/notices/:id", &update_notice_block
  patch "/api/notices/:id", &update_notice_block

  delete "/api/notices/:id" do
    if @notice.destroy
      status 204
      json status: "success"
    else
      status 500
      json status: "failed"
    end
  end
end
