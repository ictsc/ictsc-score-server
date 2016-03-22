require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

class ProblemRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/problem*" do
    I18n.locale = :en if request.xhr?
    require_login
  end

  before "/problem/:id" do
    halt 404 if not Problem.exists?(id: params[:id])
    @problem = Problem.find_by(id: params[:id])

    if request.post? || request.put? || request.patch? || request.delete?
      halt 403 if (@problem.creator_id != current_user.id) and (not current_user&.admin)
    end
  end

  get "/problem/:id" do
    json Problem.find_by(id: params[:id])
  end

  post "/problem" do
    @attrs = attribute_values_of_class(Problem)
    @attrs[:creator_id] = current_user.id
    @problem = Problem.new(@attrs)

    if @problem.save
      status 201
      headers "Location" => to("/problem/#{@problem.id}")
      json @problem
    else
      json @problem.errors
    end
  end

  update_problem_block = Proc.new do
    if request.put? and not satisfied_required_fields?(Problem)
      halt 400, { required: insufficient_fields(Problem) }.to_json
    end

    @attrs = attribute_values_of_class(Problem)
    @problem.attributes = @attrs

    halt 400, json(@problem.errors) if not @problem.valid?

    if @problem.save
      json @problem
    else
      json @problem.errors
    end
  end

  put "/problem/:id", &update_problem_block
  patch "/problem/:id", &update_problem_block

  delete "/problem/:id" do
    if @problem.destroy
      status 204
      json status: "success"
    else
      status 500
      json status: "failed"
    end
  end
end
