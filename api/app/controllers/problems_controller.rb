class ProblemsController < ApplicationController
  before_action :set_problem, only: [:show, :update, :destroy]
  before_action :before_all

  # GET /problems
  def index
    @problems = generate_nested_hash(klass: Problem, by: current_user, as_option: @as_option, params: @with_param, apply_filter: !is_admin?).uniq

    if is_participant?
      # readablesではない問題も情報を制限して返す
     @problems += Problem
        .readables(user: current_user, action: 'not_opened')
        .as_json(@as_option)
    end

    solved_teams_counts = Problem.solved_teams_counts(user: current_user)
    cleared_pg_bonuses = Score.cleared_problem_group_bonuses(team_id: current_user&.team_id)

    @problems.each do |p|
      p["solved_teams_count"] = solved_teams_counts[p["id"]]
      p["answers"]&.each do |a|
        if score = a["score"]
          score["bonus_point"]    = cleared_pg_bonuses[score["id"]] || 0
          score["subtotal_point"] = score["point"] + score["bonus_point"]
        end
      end
    end

    render json: @problems
  end

  # GET /problems/1
  def show
    solved_teams_count = Problem.solved_teams_counts(user: current_user, id: @problem.id)

    @problem = generate_nested_hash(klass: Problem, by: current_user, as_option: @as_option, params: @with_param, id: params[:id], apply_filter: !is_admin?)
    @problem["solved_teams_count"] = solved_teams_count
    @problem["answers"]&.each do |a|
      if score = a["score"]
        s = Score.find(score["id"])

        score["bonus_point"]    = s.bonus_point
        score["subtotal_point"] = s.subtotal_point
      end
    end

    render json: @problem
  end

  # POST /problems
  def create
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
      render json: @problem, status: :created, location: @problem
    else
      # render json: @problem.errors, status: :unprocessable_entity
      render json: @problem.errors, status: :bad_request
    end
  end

  # PATCH/PUT /problems/1
  def update
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
      # json @problem.as_json(@as_option)
      render json: @problem
    else
      # render json: @problem.errors, status: :unprocessable_entity
      render json: @problem.errors, status: :bad_request
    end
  end

  # DELETE /problems/1
  def destroy
    if @problem.destroy
      status 204
      json status: "success"
    else
      status 500
      json status: "failed"
    end
  end

  private
    def before_all
      I18n.locale = :en if request.xhr?

      @with_param = (params[:with] || '').split(',') & Problem.allowed_nested_params(user: current_user) if request.get?
      @as_option = { methods: [:problem_group_ids] }
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_problem
      problems = if request.get?
          Problem.includes(:comments, answers: [:score])
        else
          Problem.includes(:comments)
        end

      @problem = problems.find(params[:id])

      halt 404 if not @problem&.allowed?(by: current_user, method: request.request_method)
    end

    # Only allow a trusted parameter "white list" through.
    def problem_params
      params.fetch(:problem, {})
    end
end
