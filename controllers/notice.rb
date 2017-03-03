require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"

class NoticeRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

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

    @attrs = attribute_values_of_class(Notice)
    @attrs[:member_id] = current_user.id
    @notice = Notice.new(@attrs)

    if @notice.save
      status 201
      headers "Location" => to("/api/notices/#{@notice.id}")
      json @notice
    else
      status 400
      json @notice.errors
    end
  end

  update_notice_block = Proc.new do
    if request.put? and not satisfied_required_fields?(Notice)
      status 400
      next json required: insufficient_fields(Notice)
    end

    @attrs = attribute_values_of_class(Notice)
    @notice.attributes = @attrs

    if not @notice.valid?
      status 400
      next json @notice.errors
    end

    if @notice.save
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
