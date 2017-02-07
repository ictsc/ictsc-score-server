require "sinatra/activerecord_helpers"
require_relative "../services/account_service"

class ProblemGroupRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/api/problem_groups*" do
    I18n.locale = :en if request.xhr?
  end

  get "/api/problem_groups" do
    @problem_groups = ProblemGroup.accessible_resources(user_and_method)
    json @problem_groups
  end

  before "/api/problem_groups/:id" do
    @problem_group = ProblemGroup.accessible_resources(user_and_method) \
                      .find_by(id: params[:id])
    halt 404 if not @problem_group
  end

  get "/api/problem_groups/:id" do
    json @problem_group
  end

  post "/api/problem_groups" do
    halt 403 if not ProblemGroup.allowed_to_create_by?(current_user)

    @attrs = attribute_values_of_class(ProblemGroup)
    @problem_group = ProblemGroup.new(@attrs)

    if @problem_group.save
      status 201
      headers "Location" => to("/api/problem_groups/#{@problem_group.id}")
      json @problem_group
    else
      status 400
      json @problem_group.errors
    end
  end

  update_problem_group_block = Proc.new do
    if request.put? and not satisfied_required_fields?(ProblemGroup)
      halt 400, { required: insufficient_fields(ProblemGroup) }.to_json
    end

    @attrs = attribute_values_of_class(ProblemGroup)
    @problem_group.attributes = @attrs

    halt 400, json(@problem_group.errors) if not @problem_group.valid?

    if @problem_group.save
      json @problem_group
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
