require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

class AnswerRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/api/answers*" do
    I18n.locale = :en if request.xhr?
    require_login
  end

  get "/api/answers" do
    json Answer.all
  end

  before "/api/answers/:id" do
    halt 404 if not Answer.exists?(id: params[:id])
    @answer = Answer.find_by(id: params[:id])

    if request.post? || request.put? || request.patch? || request.delete?
      halt 403 if (@answer.team_id != current_user.team_id) and (not current_user&.admin)
    end
  end

  get "/api/answers/:id" do
    json Answer.find_by(id: params[:id])
  end

  post "/api/answers" do
    @attrs = attribute_values_of_class(Answer)
    @attrs[:team_id] = current_user.team_id
    @answer = Answer.new(@attrs)

    if @answer.save
      status 201
      headers "Location" => to("/api/answers/#{@answer.id}")
      json @answer
    else
      status 400
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
      status 400
      json @answer.errors
    end
  end

  put "/api/answers/:id", &update_answer_block
  patch "/api/answers/:id", &update_answer_block

  delete "/api/answers/:id" do
    if @answer.destroy
      status 204
      json status: "success"
    else
      status 500
      json status: "failed"
    end
  end

  before "/api/problems/:id/answers" do
    if request.post?
      halt 404 if not Problem.exists?(id: params[:id])
      @problem = Problem.find_by(id: params[:id])
    end
  end

  get "/api/problems/:id/answers" do
    @problem = Problem.find_by(id: params[:id])

    json @problem.answers
  end

  post "/api/problems/:id/answers" do
    @attrs = attribute_values_of_class(Answer)
    @attrs[:team_id] = current_user.team_id
    @attrs[:problem_id] = @problem.id
    @answer = Answer.new(@attrs)

    if @answer.save
      status 201
      headers "Location" => to("/api/answers/#{@answer.id}")
      json @answer
    else
      status 400
      json @answer.errors
    end
  end
end
