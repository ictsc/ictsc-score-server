require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

class TeamRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/api/teams*" do
    I18n.locale = :en if request.xhr?
    require_login
  end

  get "/api/teams" do
    json Team.all
  end

  before "/api/teams/:id" do
    halt 404 if not Team.exists?(id: params[:id])
    @team = Team.find_by(id: params[:id])

    if request.post? || request.put? || request.patch? || request.delete?
      halt 403 unless current_user&.admin
    end
  end

  get "/api/teams/:id" do
    json Team.find_by(id: params[:id])
  end

  post "/api/teams" do
    @attrs = attribute_values_of_class(Team)
    @team = Team.new(@attrs)

    if @team.save
      status 201
      headers "Location" => to("/api/teams/#{@team.id}")
      json @team
    else
      status 400
      json @team.errors
    end
  end

  update_team_block = Proc.new do
    if request.put? and not satisfied_required_fields?(Team)
      halt 400, { required: insufficient_fields(Team) }.to_json
    end

    @attrs = attribute_values_of_class(Team)
    @team.attributes = @attrs

    halt 400, json(@team.errors) if not @team.valid?

    if @team.save
      json @team
    else
      status 400
      json @team.errors
    end
  end

  put "/api/teams/:id", &update_team_block
  patch "/api/teams/:id", &update_team_block

  delete "/api/teams/:id" do
    if @team.destroy
      status 204
      json status: "success"
    else
      status 500
      json status: "failed"
    end
  end
end
