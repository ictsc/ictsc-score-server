require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

class ScoreRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/score*" do
    I18n.locale = :en if request.xhr?
    require_login
  end

  get "/score/:id" do
    halt 404 if not Score.exists?(id: params[:id])
    json Score.find_by(id: params[:id])
  end

  post "/score" do
    @attrs = attribute_values_of_class(Score)
    @attrs[:marker_id] = current_user.id
    @score = Score.new(@attrs)

    if @score.save
      json @score
    else
      json @score.errors
    end
  end

  update_score_block = Proc.new do
    halt 404 if not Score.exists?(id: params[:id])

    if request.put? and not satisfied_required_fields?(Score)
      halt 400, { required: insufficient_fields(Score) }.to_json
    end

    @score = Score.find_by(id: params[:id])
    @attrs = attribute_values_of_class(Score)

    @score.attributes = @attrs

    if @score.save
      json @score
    else
      json @score.errors
    end
  end

  put "/score/:id", &update_score_block
  patch "/score/:id", &update_score_block

  delete "/score/:id" do
    @score = Score.find_by(id: params[:id])
    halt 404 if @score.nil?

    if @score.destroy
      json status: "success"
    else
      json status: "failed"
    end
  end
end
