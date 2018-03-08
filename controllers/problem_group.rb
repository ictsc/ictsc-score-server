require "sinatra/activerecord_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"

class ProblemGroupRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/api/problem_groups*" do
    I18n.locale = :en if request.xhr?

    @with_param = (params[:with] || "").split(',') & ProblemGroup.allowed_nested_params(user: current_user) if request.get?
    @as_option = { methods: [:problem_ids] }
  end

  get "/api/problem_groups" do
    @problem_groups = generate_nested_hash(klass: ProblemGroup, by: current_user, as_option: @as_option, params: @with_param, apply_filter: !is_staff?)
    json @problem_groups
  end

  post "/api/problem_groups" do
    halt 403 if not ProblemGroup.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: ProblemGroup, include: [:problem_ids])

    begin
      @problem_group = ProblemGroup.new(@attrs)
    rescue ActiveRecord::RecordNotFound
      status 400
      next json problem_ids: "存在しないレコードです"
    end

    if @problem_group.save
      status 201
      headers "Location" => to("/api/problem_groups/#{@problem_group.id}")
      json @problem_group.as_json(@as_option)
    else
      status 400
      json @problem_group.errors
    end
  end

  before "/api/problem_groups/:id" do
    @problem_group = ProblemGroup.find_by(id: params[:id])
    halt 404 if not @problem_group&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/problem_groups/:id" do
    @problem_group = generate_nested_hash(klass: ProblemGroup, by: current_user, as_option: @as_option, params: @with_param, id: params[:id], apply_filter: !is_staff?)
    json @problem_group
  end

  update_problem_group_block = Proc.new do
    if request.put? and not filled_all_attributes_of?(klass: ProblemGroup)
      status 400
      next json required: insufficient_attribute_names_of(klass: ProblemGroup)
    end

    @attrs = params_to_attributes_of(klass: ProblemGroup)
    @problem_group.attributes = @attrs

    if not @problem_group.valid?
      status 400
      next json @problem_group.errors
    end

    begin
      @problem_group.problem_ids = params[:problem_ids]
    rescue ActiveRecord::RecordNotFound
      status 400
      next json problem_ids: "存在しないレコードです"
    end

    if @problem_group.save
      json @problem_group.as_json(@as_option)
    else
      status 400
      json @problem_group.errors
    end
  end

  put "/api/problem_groups/:id", &update_problem_group_block
  patch "/api/problem_groups/:id", &update_problem_group_block

  delete "/api/problem_groups/:id" do
    if @problem_group.destroy
      status 204
      json status: "success"
    else
      status 500
      json status: "failed"
    end
  end
end
