require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

class AnswerRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/answers*" do
    I18n.locale = :en if request.xhr?
    require_login
  end

  before "/answers/:id" do
    halt 404 if not Answer.exists?(id: params[:id])
    @answer = Answer.find_by(id: params[:id])

    if request.post? || request.put? || request.patch? || request.delete?
      halt 403 if (@answer.team_id != current_user.team_id) and (not current_user&.admin)
    end
  end

  get "/answers/:id" do
    json Answer.find_by(id: params[:id])
  end

  post "/answers" do
    @attrs = attribute_values_of_class(Answer)
    @answer = Answer.new(@attrs)

    if @answer.save
      status 201
      headers "Location" => to("/answers/#{@answer.id}")
      json @answer
    else
      json @answer.errors
    end
  end

  update_answer_block = Proc.new do
    if request.put? and not satisfied_required_fields?(Answer)
      halt 400, { required: insufficient_fields(Answer) }.to_json
    end

    @attrs = attribute_values_of_class(Answer)
    @answer.attributes = @attrs

    halt 400, json(@answer.errors) if not @answer.valid?

    if @answer.save
      json @answer
    else
      json @answer.errors
    end
  end

  put "/answers/:id", &update_answer_block
  patch "/answers/:id", &update_answer_block

  delete "/answers/:id" do
    if @answer.destroy
      status 204
      json status: "success"
    else
      status 500
      json status: "failed"
    end
  end
end
