require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

class AnswerRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/api/answers*" do
    I18n.locale = :en if request.xhr?
  end

  get "/api/answers" do
    @answers = Answer.readables(user: current_user) \
                     .map{|x| x.attributes.merge(score_id: x&.score&.id) }
    json @answers
  end

  before "/api/answers/:id" do
    @answer = Answer.find_by(id: params[:id])
    halt 404 if not @answer&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/answers/:id" do
    json @answer.attributes.merge(score_id: @answer&.score&.id)
  end

  post "/api/answers" do
    halt 403 if not Answer.allowed_to_create_by?(current_user)

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
    @problem = Problem.find_by(id: params[:id])
    halt 404 if not @problem&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/problems/:id/answers" do
    @answers = Answer.readables(user: current_user) \
                     .where(problem: @problem)
    json @answers
  end

  post "/api/problems/:id/answers" do
    halt 403 if not Answer.allowed_to_create_by?(current_user)

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
