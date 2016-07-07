require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

class ScoreRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/api/scores*" do
    I18n.locale = :en if request.xhr?
  end

  get "/api/scores" do
    @scores = Score.accessible_resources(user_and_method)
    json @scores
  end

  before "/api/scores/:id" do
    @score = Score.accessible_resources(user_and_method) \
                  .find_by(id: params[:id])
    halt 404 if not @score
  end

  get "/api/scores/:id" do
    json @score
  end

  post "/api/scores" do
    halt 403 if not Score.allowed_to_create_by?(current_user)

    @attrs = attribute_values_of_class(Score)
    @attrs[:marker_id] = current_user.id
    @score = Score.new(@attrs)

    if @score.save
      status 201
      headers "Location" => to("/api/scores/#{@score.id}")
      json @score
    else
      json @score.errors
    end
  end

  update_score_block = Proc.new do
    if request.put? and not satisfied_required_fields?(Score)
      halt 400, { required: insufficient_fields(Score) }.to_json
    end

    @attrs = attribute_values_of_class(Score)
    @score.attributes = @attrs

    halt 400, json(@score.errors) if not @score.valid?

    if @score.save
      json @score
    else
      json @score.errors
    end
  end

  put "/api/scores/:id", &update_score_block
  patch "/api/scores/:id", &update_score_block

  delete "/api/scores/:id" do
    if @score.destroy
      status 204
      json status: "success"
    else
      status 500
      json status: "failed"
    end
  end

  before "/api/answers/:id/score" do
    @answer = Answer.accessible_resources(user: current_user, method: "GET") \
                    .find_by(id: params[:id])
    halt 404 if @answer.nil?
  end

  get "/api/answers/:id/score" do
    halt 404 if @answer.score.nil?
    @score = Score.accessible_resources(user_and_method) \
                  .find_by(id: @answer.score.id)

    status 303
    headers "Location" => to("/api/scores/#{@score.id}")
  end

  post "/api/answers/:id/score" do
    halt 403 if not Score.allowed_to_create_by?(current_user)

    @attrs = attribute_values_of_class(Score)
    @attrs[:marker_id] = current_user.id
    @attrs[:answer_id] = @answer.id
    @score = Score.new(@attrs)

    if @score.save
      status 201
      headers "Location" => to("/api/scores/#{@score.id}")
      json @score
    else
      json @score.errors
    end
  end
end
