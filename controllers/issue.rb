require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"

class IssueRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/api/issues*" do
    I18n.locale = :en if request.xhr?

    @with_param = (params[:with] || "").split(',') & Issue.allowed_nested_params(user: current_user) if request.get?
  end

  get "/api/issues" do
    @issues = generate_nested_hash(klass: Issue, by: current_user, params: @with_param, apply_filter: !is_admin?)
    json @issues
  end

  before "/api/issues/:id" do
    @issue = Issue.includes(:comments)
                  .find_by(id: params[:id])
    halt 404 if not @issue&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/issues/:id" do
    @issue = generate_nested_hash(klass: Issue, by: current_user, params: @with_param, id: params[:id], apply_filter: !is_admin?)

    json @issue
  end

  update_issue_block = Proc.new do
    if request.put? and not filled_all_attributes_of?(klass: Issue)
      status 400
      next json required: insufficient_attribute_names_of(klass: Issue)
    end

    @attrs = params_to_attributes_of(klass: Issue)
    @issue.attributes = @attrs

    if not @issue.valid?
      status 400
      next json @issue.errors
    end

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
    @problem = Problem.find_by(id: params[:id])
    pass if request.post? and @problem&.allowed?(by: current_user, method: 'GET')
    halt 404 if not @problem&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/problems/:id/issues" do
    @issues = Issue.readables(user: current_user)
                   .where(problem_id: @problem.id)
    json @issues
  end

  post "/api/problems/:id/issues" do
    halt 403 if not Issue.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Issue)
    @attrs[:team_id] = current_user.team_id if not %w(Admin Writer).include? current_user&.role&.name
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
