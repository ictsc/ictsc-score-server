require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"

class ProblemRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/api/problems*" do
    I18n.locale = :en if request.xhr?

    @with_param = (params[:with] || "").split(?,) & %w(answers answers-comments answers-score issues issues-comments creator) if request.get?
  end

  get "/api/problems" do
    @problems = generate_nested_hash(klass: Problem, by: current_user, params: @with_param).uniq

    if "Participant" == current_user&.role&.name
      show_columns = Problem.column_names - %w(title text)
      @problems = (@problems + Problem.where.not(id: @problems.map{|x| x["id"]}).select(*show_columns).as_json).sort_by{|x| x["id"] }
    end

    # NOTE select "reference_point" is needed because of used in having clause
    solved_teams_count_by_problem = Problem \
      .all \
      .joins(answers: [:score]) \
      .group(:id, "answers.team_id") \
      .having("SUM(scores.point) >= problems.reference_point") \
      .select("id", "answers.team_id", "reference_point") \
      .inject(Hash.new(0)){|acc, p| acc[p.id] += 1; acc }

    @problems.each do |p|
      p["solved_teams_count"] = solved_teams_count_by_problem[p["id"]]
      p["creator"]&.delete("hashed_password")
    end

    json @problems
  end

  before "/api/problems/:id" do
    problems = if request.request_method == "GET"
        Problem.includes(:comments, answers: [:score])
      else
        Problem.includes(:comments)
      end

    @problem = problems.find_by(id: params[:id])

    halt 404 if not @problem&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/problems/:id" do
    solved_teams_count = Answer \
      .joins(:score) \
      .where(problem_id: @problem.id) \
      .group(:team_id) \
      .having("SUM(scores.point) >= ?", @problem.reference_point) \
      .count \
      .count

    @problem = generate_nested_hash(klass: Problem, by: current_user, params: @with_param, id: params[:id])
    @problem["solved_teams_count"] = solved_teams_count
    @problem["creator"]&.delete("hashed_password")

    json @problem
  end

  post "/api/problems" do
    halt 403 if not Problem.allowed_to_create_by?(current_user)

    @attrs = attribute_values_of_class(Problem)
    @attrs[:creator_id] = current_user.id
    @problem = Problem.new(@attrs)

    if @problem.save
      status 201
      headers "Location" => to("/api/problems/#{@problem.id}")
      json @problem
    else
      status 400
      json @problem.errors
    end
  end

  update_problem_block = Proc.new do
    if request.put? and not satisfied_required_fields?(Problem)
      status 400
      next json required: insufficient_fields(Problem)
    end

    @attrs = attribute_values_of_class(Problem)
    @problem.attributes = @attrs

    if not @problem.valid?
      status 400
      next json @problem.errors
    end

    if @problem.save
      json @problem
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
