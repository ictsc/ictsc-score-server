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

  before "/team/:id" do
    halt 404 if not Team.exists?(id: params[:id])
    @team = Team.find_by(id: params[:id])

    if request.post? || request.put? || request.patch? || request.delete?
      halt 403 unless current_user&.admin
    end
  end

  get "/team/:id" do
    json Team.find_by(id: params[:id])
  end

  post "/team" do
    @attrs = attribute_values_of_class(Team)
    @team = Team.new(@attrs)

    if @team.save
      status 201
      headers "Location" => to("/team/#{@team.id}")
      json @team
    else
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
      json @team.errors
    end
  end

  put "/team/:id", &update_team_block
  patch "/team/:id", &update_team_block

  delete "/team/:id" do
    if @team.destroy
      status 204
      json status: "success"
    else
      status 500
      json status: "failed"
    end
  end
end
