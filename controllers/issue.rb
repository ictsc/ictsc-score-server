require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

class IssueRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/api/issues*" do
    I18n.locale = :en if request.xhr?
    require_login
  end

  get "/api/issues" do
    @issues = Issue.accessible_resources(user_and_method)
    json @issues
  end

  before "/api/issues/:id" do
    @issue = Issue.accessible_resources(user_and_method) \
                  .find_by(id: params[:id])
    halt 404 if not @issue
  end

  get "/api/issues/:id" do
    json @issue
  end

  post "/api/issues" do
    halt 403 if not Issue.allowed_to_create_by?(current_user)

    @attrs = attribute_values_of_class(Issue)
    @attrs[:team_id] = current_user.team_id
    @issue = Issue.new(@attrs)

    if @issue.save
      status 201
      headers "Location" => to("/api/issues/#{@issue.id}")
      json @issue
    else
      status 400
      json @issue.errors
    end
  end

  update_issue_block = Proc.new do
    if request.put? and not satisfied_required_fields?(Issue)
      halt 400, { required: insufficient_fields(Issue) }.to_json
    end

    @attrs = attribute_values_of_class(Issue)
    @issue.attributes = @attrs

    halt 400, json(@issue.errors) if not @issue.valid?

    if @issue.save
      json @issue
    else
      status 400
      json @issue.errors
    end
  end

  put "/api/issues/:id", &update_issue_block
  patch "/api/issues/:id", &update_issue_block

  delete "/api/issues/:id" do
    if @issue.destroy
      status 204
      json status: "success"
    else
      status 500
      json status: "failed"
    end
  end

  before "/api/problems/:id/issues" do
    @problem = Problem.accessible_resources(user: current_user, method: "GET") \
                      .find_by(id: params[:id])
    halt 404 if not @problem
  end

  get "/api/problems/:id/issues" do
    @issues = Issue.accessible_resources(user_and_method) \
                   .where(problem_id: @problem.id)
    json @issues
  end

  post "/api/problems/:id/issues" do
    halt 403 if not Issue.allowed_to_create_by?(current_user)

    @attrs = attribute_values_of_class(Issue)
    @attrs[:team_id] = current_user.team_id
    @attrs[:problem_id] = @problem.id
    @issue = Issue.new(@attrs)

    if @issue.save
      status 201
      headers "Location" => to("/api/issues/#{@issue.id}")
      json @issue
    else
      status 400
      json @issue.errors
    end
  end
end
