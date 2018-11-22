class ScoresController < ApplicationController
  before_action :before_all
  before_action :set_score, only: [:show, :update, :destroy]

  # GET /scores
  def index
    @scores = generate_nested_hash(klass: Score, by: current_user, params: @with_param, apply_filter: !is_admin?)

    # NOTE: Calculate each Score#cleared_problem_group? is too slow
    # So, fetch cleared problem ids first, and calculate each entities using it.
    cleared_pg_bonuses = Score.cleared_problem_group_bonuses(team_id: current_user&.team_id)

    # @scores_array = @scores.as_json
    @scores.each do |s|
      s["bonus_point"]    = cleared_pg_bonuses[s["id"]] || 0
      s["subtotal_point"] = s["point"] + s["bonus_point"]
    end

    render json: @scores
  end

  # GET /scores/1
  def show
    @as_option = { methods: [:bonus_point, :subtotal_point] }
    @score = generate_nested_hash(klass: Score, by: current_user, params: @with_param, id: params[:id], as_option: @as_option, apply_filter: !is_admin?)

    # json @score #, { methods: [:bonus_point, :subtotal_point] }
    render json: @score
  end

  # POST /scores
  def create
    @score = Score.new(score_params)

    if @score.save
      render json: @score, status: :created, location: @score
    else
      render json: @score.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /scores/1
  def update
    if request.put? and not filled_all_attributes_of?(klass: Score)
      status 400
      next json required: insufficient_attribute_names_of(klass: Score)
    end

    @attrs = params_to_attributes_of(klass: Score)
    @score.attributes = @attrs

    if not @score.valid?
      status 400
      next json @score.errors
    end

    if @score.save
      render json: @score
    else
      # render json: @score.errors, status: :unprocessable_entity
      render json: @score.errors, status: :bad_request
    end
  end

  # DELETE /scores/1
  def destroy
    if @score.destroy
      render json: {status: "success"}, status: 204
    else
      render json: {status: "failed"}, status: 500
    end
  end

  private
    def before_all
      I18n.locale = :en if request.xhr?

      @with_param = (params[:with] || "").split(',') & Score.allowed_nested_params(user: current_user) if request.get?
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_score
      @score = Score.find(params[:id])
      halt 404 if not @score&.allowed?(by: current_user, method: request.request_method)
    end

    # Only allow a trusted parameter "white list" through.
    def score_params
      params.fetch(:score, {})
    end
end
