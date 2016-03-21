require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

class AnswerRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/answer*" do
    I18n.locale = :en if request.xhr?
    require_login
  end

  get "/answer/:id" do
    halt 404 if not Answer.exists?(id: params[:id])
    json Answer.find_by(id: params[:id])
  end

  post "/answer" do
    @attrs = attribute_values_of_class(Answer)
    @answer = Answer.new(@attrs)

    if @answer.save
      json @answer
    else
      json @answer.errors
    end
  end

  update_answer_block = Proc.new do
    halt 404 if not Answer.exists?(id: params[:id])

    if request.put? and not satisfied_required_fields?(Answer)
      halt 400, { required: insufficient_fields(Answer) }.to_json
    end

    @answer = Answer.find_by(id: params[:id])
    @attrs = attribute_values_of_class(Answer)

    @answer.attributes = @attrs

    if @answer.save
      json @answer
    else
      json @answer.errors
    end
  end

  put "/answer/:id", &update_answer_block
  patch "/answer/:id", &update_answer_block

  delete "/answer/:id" do
    @answer = Answer.find_by(id: params[:id])
    halt 404 if @answer.nil?

    if @answer.destroy
      json status: "success"
    else
      json status: "failed"
    end
  end
end
