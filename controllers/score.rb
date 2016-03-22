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

  before "/score/:id" do
    halt 404 if not Score.exists?(id: params[:id])
    @score = Score.find_by(id: params[:id])

    if request.post? || request.put? || request.patch? || request.delete?
      halt 403 if (@score.marker_id != current_user.id) and (not current_user&.admin)
    end
  end

  get "/score/:id" do
    json Score.find_by(id: params[:id])
  end

  post "/score" do
    @attrs = attribute_values_of_class(Score)
    @attrs[:marker_id] = current_user.id
    @score = Score.new(@attrs)

    if @score.save
      status 201
      headers "Location" => to("/score/#{@score.id}")
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

  put "/score/:id", &update_score_block
  patch "/score/:id", &update_score_block

  delete "/score/:id" do
    if @score.destroy
      status 204
      json status: "success"
    else
      status 500
      json status: "failed"
    end
  end
end
