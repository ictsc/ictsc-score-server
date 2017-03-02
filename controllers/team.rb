require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"

class TeamRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/api/teams*" do
    I18n.locale = :en if request.xhr?

    @with_param = (params[:with] || "").split(?,) & %w(members answers answers-score answers-comments answers-comments-member issues issues-comments issues-comments-member) if request.get?
  end

  get "/api/teams" do
    @teams = generate_nested_hash(klass: Team, by: current_user, params: @with_param) \
      .map do |t|
        t["hashed_registration_code"] = Digest::SHA1.hexdigest(t["registration_code"])
        t.delete("registration_code") if not %w(Admin Writer).include? current_user&.role&.name
        t["members"]&.each {|m| m.delete("hashed_password") }
        t["answers"]&.each {|a| a["comments"]&.each {|c| c["member"]&.delete("hashed_password") } }
        t["issues"]&.each {|a| a["comments"]&.each {|c| c["member"]&.delete("hashed_password") } }
        t
      end
    json @teams
  end

  before "/api/teams/:id" do
    @team = Team.find_by(id: params[:id])
    halt 404 if not @team&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/teams/:id" do
    @team = generate_nested_hash(klass: Team, by: current_user, params: @with_param, id: params[:id])
    @team["hashed_registration_code"] = Digest::SHA1.hexdigest(@team["registration_code"])
    @team.delete("registration_code") if not %w(Admin Writer).include? current_user&.role&.name
    @team["members"]&.map{|m| m.delete("hashed_password") }
    @team["answers"]&.each {|a| a["comments"]&.each {|c| c["member"]&.delete("hashed_password") } }
    @team["issues"]&.each {|a| a["comments"]&.each {|c| c["member"]&.delete("hashed_password") } }
    json @team
  end

  post "/api/teams" do
    halt 403 if not Team.allowed_to_create_by?(current_user)

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
      status 400
      next json required: insufficient_fields(Team)
    end

    @attrs = attribute_values_of_class(Team)
    @team.attributes = @attrs

    if not @team.valid?
      status 400
      next json @team.errors
    end

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
