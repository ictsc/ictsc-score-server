require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require "sinatra/config_file"
require_relative "../services/account_service"

class ScoreRoutes < Sinatra::Base
  register Sinatra::ConfigFile
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  config_file Pathname(settings.root).parent + "config/contest.yml"

  before "/api/scores*" do
    I18n.locale = :en if request.xhr?
  end

  get "/api/scores" do
    @scores = Score.readables(user: current_user)
    firstblood_ids = Score.firstbloods(only_ids: true)
    @scores_array = @scores.as_json
    @scores_array.each do |score_array|
      score_array["is_firstblood"]  = firstblood_ids.include? score_array["id"]
      score_array["bonus_point"]    = score_array["is_firstblood"] ? (score_array["point"] * settings.first_blood_bonus_percentage / 100.0).to_i : 0
      score_array["subtotal_point"] = score_array["point"] + score_array["bonus_point"]
    end

    json @scores_array
  end

  before "/api/scores/:id" do
    @score = Score.find_by(id: params[:id])
    halt 404 if not @score&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/scores/:id" do
    json @score, { methods: [:is_firstblood, :bonus_point, :subtotal_point] }
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
      status 400
      json @score.errors
    end
  end

  update_score_block = Proc.new do
    if request.put? and not satisfied_required_fields?(Score)
      status 400
      next json required: insufficient_fields(Score)
    end

    @attrs = attribute_values_of_class(Score)
    @score.attributes = @attrs

    if not @score.valid?
      status 400
      next json @score.errors
    end

    if @score.save
      json @score
    else
      status 400
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
    @answer = Answer.find_by(id: params[:id])
    halt 404 if @answer&.allowed?(by: current_user, method: "GET")
  end

  get "/api/answers/:id/score" do
    halt 404 if @answer.score.nil?
    @score = Score.find_by(id: @answer.score.id)
    halt 404 if @score&.allowed?(by: current_user, method: request.request_method)

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
