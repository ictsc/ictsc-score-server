require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

class TeamRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/team*" do
    I18n.locale = :en if request.xhr?
    require_login
  end

  get "/team/:id" do
    halt 404 if not Team.exists?(id: params[:id])
    json Team.find_by(id: params[:id])
  end

  post "/team" do
    @attrs = attribute_values_of_class(Team)
    @team = Team.new(@attrs)

    if @team.save
      json @team
    else
      json @team.errors
    end
  end

  update_team_block = Proc.new do
    halt 404 if not Team.exists?(id: params[:id])

    if request.put? and not satisfied_required_fields?(Team)
      halt 400, { required: insufficient_fields(Team) }.to_json
    end

    @team = Team.find_by(id: params[:id])
    @attrs = attribute_values_of_class(Team)

    @team.attributes = @attrs

    if @team.save
      json @team
    else
      json @team.errors
    end
  end

  put "/team/:id", &update_team_block
  patch "/team/:id", &update_team_block

  delete "/team/:id" do
    @team = Team.find_by(id: params[:id])
    halt 404 if @team.nil?

    if @team.destroy
      json status: "success"
    else
      json status: "failed"
    end
  end
end
