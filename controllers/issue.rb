require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

class IssueRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/issue*" do
    I18n.locale = :en if request.xhr?
    require_login
  end

  before "/issue/:id" do
    halt 404 if not Issue.exists?(id: params[:id])
    @issue = Issue.find_by(id: params[:id])

    if request.post? || request.put? || request.patch? || request.delete?
      halt 403 if not current_user&.admin
    end
  end

  get "/issue/:id" do
    json Issue.find_by(id: params[:id])
  end

  post "/issue" do
    @attrs = attribute_values_of_class(Issue)
    @issue = Issue.new(@attrs)

    if @issue.save
      status 201
      headers "Location" => to("/issue/#{@issue.id}")
      json @issue
    else
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
      json @issue.errors
    end
  end

  put "/issue/:id", &update_issue_block
  patch "/issue/:id", &update_issue_block

  delete "/issue/:id" do
    if @issue.destroy
      status 204
      json status: "success"
    else
      status 500
      json status: "failed"
    end
  end
end
