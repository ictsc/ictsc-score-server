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

    @with_param = (params[:with] || "").split(?,) & %w(comments comments-member comments-member-team team problem) if request.get?
  end

  get "/api/issues" do
    @issues = generate_nested_hash(klass: Issue, by: current_user, params: @with_param)
    @issues.each do |i|
      i.dig("team")&.delete("registration_code")
      i.dig("comments")&.each do |c|
        c.dig("member")&.delete("hashed_password")
        c.dig("member", "team")&.delete("registration_code")
      end
    end
    json @issues
  end

  before "/api/issues/:id" do
    @issue = Issue.includes(:comments) \
                  .find_by(id: params[:id])
    halt 404 if not @issue&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/issues/:id" do
    @issue = generate_nested_hash(klass: Issue, by: current_user, params: @with_param, id: params[:id])
    @issue.dig("team")&.delete("registration_code")
    @issue.dig("comments")&.each do |c|
      c.dig("member")&.delete("hashed_password")
      c.dig("member", "team")&.delete("registration_code")
    end

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
      status 400
      next json required: insufficient_fields(Issue)
    end

    @attrs = attribute_values_of_class(Issue)
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
    halt 404 if not @problem&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/problems/:id/issues" do
    @issues = Issue.readables(user: current_user) \
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
