require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"
require_relative "../services/notification_service"

class ScoreRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers
  helpers Sinatra::NotificationService

  before "/api/answers/:id/score" do
    @answer = Answer.find_by(id: params[:id])
    halt 404 if not @answer&.allowed?(by: current_user, method: "GET")
  end

  get "/api/answers/:id/score" do
    halt 404 if @answer.score.nil?
    @score = Score.find_by(id: @answer.score.id)
    halt 404 if not @score&.allowed?(by: current_user, method: request.request_method)

    status 303
    headers "Location" => to("/api/scores/#{@score.id}")
  end

  post "/api/answers/:id/score" do
    halt 403 if not Score.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Score)
    @attrs[:marker_id] = current_user.id if !is_admin? || @attrs[:marker_id].nil?
    @attrs[:answer_id] = @answer.id
    @score = Score.new(@attrs)

    if @score.save
      @answer = @score.answer
      notification_payload = @score.notification_payload
      push_notification(to: @answer.team, payload: notification_payload) if notification_payload.dig(:data, :notify_at) <= Setting.competition_end_at

      status 201
      headers "Location" => to("/api/scores/#{@score.id}")
      json @score
    else
      status 400
      json @score.errors
    end
  end
end
