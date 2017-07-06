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
    @teams = generate_nested_hash(klass: Team, by: current_user, params: @with_param, apply_filter: !(is_admin? || is_viewer?)) \
      .map do |t|
        t["hashed_registration_code"] = Digest::SHA1.hexdigest(t["registration_code"])
        t.delete("registration_code") if not %w(Admin Writer).include? current_user&.role&.name
        t["members"]&.each {|m| m.delete("hashed_password") }
        t["answers"]&.each {|a| a["comments"]&.each {|c| c["member"]&.delete("hashed_password") } }
        t["issues"]&.each {|a| a["comments"]&.each {|c| c["member"]&.delete("hashed_password") } }
        t
      end

    if @with_param.include? "answers-score"
      firstblood_ids = Score.firstbloods(only_ids: true)
      cleared_pg_ids = Score.cleared_problem_group_ids(team_id: current_user&.team_id)

      @teams.each do |t|
        t["answers"]&.each do |a|
          if s = a["score"]
            s["is_firstblood"]  = firstblood_ids.include? s["id"]

            bonus_point = 0
            bonus_point += (s["point"] * Setting.first_blood_bonus_percentage / 100.0).to_i if s["is_firstblood"]
            bonus_point += Setting.bonus_point_for_clear_problem_group if cleared_pg_ids.include? s["id"]

            s["bonus_point"]    = bonus_point
            s["subtotal_point"] = s["point"] + s["bonus_point"]

            a["score"] = s
          end
        end
      end
    end

    json @teams
  end

  before "/api/teams/:id" do
    @team = Team.find_by(id: params[:id])
    halt 404 if not @team&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/teams/:id" do
    @team = generate_nested_hash(klass: Team, by: current_user, params: @with_param, id: params[:id], apply_filter: !(is_admin? || is_viewer?))
    @team["hashed_registration_code"] = Digest::SHA1.hexdigest(@team["registration_code"])
    @team.delete("registration_code") if not %w(Admin Writer).include? current_user&.role&.name
    @team["members"]&.map{|m| m.delete("hashed_password") }
    @team["answers"]&.each {|a| a["comments"]&.each {|c| c["member"]&.delete("hashed_password") } }
    @team["issues"]&.each {|a| a["comments"]&.each {|c| c["member"]&.delete("hashed_password") } }

    if @with_param.include? "answers-score"
      firstblood_ids = Score.firstbloods(only_ids: true)
      cleared_pg_ids = Score.cleared_problem_group_ids(team_id: current_user&.team_id)

      @team["answers"]&.each do |a|
        if s = a["score"]
          s["is_firstblood"]  = firstblood_ids.include? s["id"]

          bonus_point = 0
          bonus_point += (s["point"] * Setting.first_blood_bonus_percentage / 100.0).to_i if s["is_firstblood"]
          bonus_point += Setting.bonus_point_for_clear_problem_group if cleared_pg_ids.include? s["id"]

          s["bonus_point"]    = bonus_point
          s["subtotal_point"] = s["point"] + s["bonus_point"]

          a["score"] = s
        end
      end
    end

    json @team
  end

  post "/api/teams" do
    halt 403 if not Team.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Team)
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
    if request.put? and not filled_all_attributes_of?(klass: Team)
      status 400
      next json required: insufficient_attribute_names_of(klass: Team)
    end

    @attrs = params_to_attributes_of(klass: Team)
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
