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

  get "/issue/:id" do
    halt 404 if not Issue.exists?(id: params[:id])
    json Issue.find_by(id: params[:id])
  end

  post "/issue" do
    @attrs = attribute_values_of_class(Issue)
    @issue = Issue.new(@attrs)

    if @issue.save
      json @issue
    else
      json @issue.errors
    end
  end

  update_issue_block = Proc.new do
    halt 404 if not Issue.exists?(id: params[:id])

    if request.put? and not satisfied_required_fields?(Issue)
      halt 400, { required: insufficient_fields(Issue) }.to_json
    end

    @issue = Issue.find_by(id: params[:id])
    @attrs = attribute_values_of_class(Issue)

    @issue.attributes = @attrs

    if @issue.save
      json @issue
    else
      json @issue.errors
    end
  end

  put "/issue/:id", &update_issue_block
  patch "/issue/:id", &update_issue_block

  delete "/issue/:id" do
    @issue = Issue.find_by(id: params[:id])
    halt 404 if @issue.nil?

    if @issue.destroy
      json status: "success"
    else
      json status: "failed"
    end
  end
end
