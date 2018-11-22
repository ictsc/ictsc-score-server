require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"
require_relative "../services/notification_service"

class AnswerRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers
  helpers Sinatra::NotificationService


  before "/api/problems/:id/answers" do
    # Problemのフィルタを使うから注意
    @problem = Problem.find_by(id: params[:id])
    pass if request.post? and @problem&.allowed?(by: current_user, method: 'GET')
    halt 404 if not @problem&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/problems/:id/answers" do
    @answers = Answer.readables(user: current_user)
                     .where(problem: @problem)
    json @answers
  end

  post "/api/problems/:id/answers" do
    halt 403 if not Answer.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Answer)
    @attrs[:team_id] = current_user.team_id if not is_admin?
    @attrs[:problem_id] = @problem.id
    @answer = Answer.new(@attrs)

    if @answer.save
      push_notification(to: Role.where(name: %w(Admin Writer)), payload: @answer.notification_payload)

      status 201
      headers "Location" => to("/api/answers/#{@answer.id}")
      json @answer
    else
      status 400
      json @answer.errors
    end
  end
end
