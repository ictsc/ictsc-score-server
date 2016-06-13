require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

class ScoreRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/api/scores*" do
    I18n.locale = :en if request.xhr?
    require_login
  end

  get "/api/scores" do
    json Score.all
  end

  before "/api/scores/:id" do
    halt 404 if not Score.exists?(id: params[:id])
    @score = Score.find_by(id: params[:id])

    if request.post? || request.put? || request.patch? || request.delete?
      halt 403 if (@score.marker_id != current_user.id) and (not current_user&.admin)
    end
  end

  get "/api/scores/:id" do
    json Score.find_by(id: params[:id])
  end

  post "/api/scores" do
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
    halt 404 if not Answer.exists?(id: params[:id])
    @answer = Answer.find_by(id: params[:id])

    halt 404 if @answer.score.nil?
    @score = @answer.score

    if request.post? || request.put? || request.patch? || request.delete?
      halt 403 if (@score.marker_id != current_user.id) and (not current_user&.admin)
    end
  end

  get "/api/answers/:id/score" do
    status 303
    headers "Location" => to("/api/scores/#{@score.id}")
  end

  post "/api/answers/:id/score" do
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
