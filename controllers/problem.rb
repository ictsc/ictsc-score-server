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

  get "/problem/:id" do
    halt 404 if not Problem.exists?(id: params[:id])
    json Problem.find_by(id: params[:id])
  end

  post "/problem" do
    @attrs = attribute_values_of_class(Problem)
    @attrs[:creator_id] = current_user.id
    @problem = Problem.new(@attrs)

    if @problem.save
      json @problem
    else
      json @problem.errors
    end
  end

  update_problem_block = Proc.new do
    halt 404 if not Problem.exists?(id: params[:id])

    if request.put? and not satisfied_required_fields?(Problem)
      halt 400, { required: insufficient_fields(Problem) }.to_json
    end

    @problem = Problem.find_by(id: params[:id])
    @attrs = attribute_values_of_class(Problem)

    @problem.attributes = @attrs

    if @problem.save
      json @problem
    else
      json @problem.errors
    end
  end

  put "/problem/:id", &update_problem_block
  patch "/problem/:id", &update_problem_block

  delete "/problem/:id" do
    @problem = Problem.find_by(id: params[:id])
    halt 404 if @problem.nil?

    if @problem.destroy
      json status: "success"
    else
      json status: "failed"
    end
  end
end
