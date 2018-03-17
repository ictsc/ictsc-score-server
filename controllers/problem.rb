require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require "sinatra/competition_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"

class ProblemRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers
  helpers Sinatra::CompetitionHelpers

  before "/api/problems*" do
    I18n.locale = :en if request.xhr?

    @with_param = (params[:with] || '').split(',') & Problem.allowed_nested_params(user: current_user) if request.get?
    @as_option = { methods: [:problem_group_ids] }
  end

  get "/api/problems" do
    @problems = generate_nested_hash(klass: Problem, by: current_user, as_option: @as_option, params: @with_param, apply_filter: !is_admin?).uniq

    if is_participant?
      next json [] unless in_competition?

      # readablesではない問題も情報を制限して返す
      @problems += Problem
        .readables(user: current_user, action: 'not_open')
        .as_json(@as_option)
    end

    solved_teams_count_by_problem = FirstCorrectAnswer
      .readables(user: current_user, action: 'for_count')
      .each_with_object(Hash.new(0)){|fca, memo| memo[fca.problem_id] += 1 }

    cleared_pg_bonuses = Score.cleared_problem_group_bonuses(team_id: current_user&.team_id)

    @problems.each do |p|
      p["solved_teams_count"] = solved_teams_count_by_problem[p["id"]] || 0
      p["answers"]&.each do |a|
        if score = a["score"]
          score["bonus_point"]    = cleared_pg_bonuses[score["id"]] || 0
          score["subtotal_point"] = score["point"] + score["bonus_point"]
        end
      end
    end

    json @problems
  end

  post "/api/problems" do
    halt 403 if not Problem.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Problem, include: [:problem_group_ids])

    begin
      @problem = Problem.new(@attrs)
    rescue ActiveRecord::RecordNotFound
      status 400
      next json problem_group_ids: "存在しないレコードです"
    end

    if @problem.save
      status 201
      headers "Location" => to("/api/problems/#{@problem.id}")
      json @problem.as_json(@as_option)
    else
      status 400
      json @problem.errors
    end
  end

  before "/api/problems/:id" do
    problems = if request.get?
        Problem.includes(:comments, answers: [:score])
      else
        Problem.includes(:comments)
      end

    @problem = problems.find_by(id: params[:id])

    halt 404 if not @problem&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/problems/:id" do
    solved_teams_count = FirstCorrectAnswer
      .where(problem: @problem)
      .readables(user: current_user, action: 'for_count')
      .count(:id) # readablesでselectしてるからカラムの指定が必要

    @problem = generate_nested_hash(klass: Problem, by: current_user, as_option: @as_option, params: @with_param, id: params[:id], apply_filter: !is_admin?)
    @problem["solved_teams_count"] = solved_teams_count
    @problem["answers"]&.each do |a|
      if score = a["score"]
        s = Score.find(score["id"])

        score["bonus_point"]    = s.bonus_point
        score["subtotal_point"] = s.subtotal_point
      end
    end

    json @problem
  end

  update_problem_block = Proc.new do
    if request.put? and not filled_all_attributes_of?(klass: Problem)
      status 400
      next json required: insufficient_attribute_names_of(klass: Problem)
    end

    @attrs = params_to_attributes_of(klass: Problem)
    @problem.attributes = @attrs

    if not @problem.valid?
      status 400
      next json @problem.errors
    end

    begin
      @problem.problem_group_ids = params[:problem_group_ids]
    rescue ActiveRecord::RecordNotFound
      status 400
      next json problem_group_ids: "存在しないレコードです"
    end

    if @problem.save
      json @problem.as_json(@as_option)
    else
      status 400
      json @problem.errors
    end
  end

  put "/api/problems/:id", &update_problem_block
  patch "/api/problems/:id", &update_problem_block

  delete "/api/problems/:id" do
    if @problem.destroy
      status 204
      json status: "success"
    else
      status 500
      json status: "failed"
    end
  end
end
