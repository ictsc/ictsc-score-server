class AnswersController < ApplicationController
  before_action :set_answer, only: [:show, :update, :destroy]
  before_action :all_before

  # GET /answers
  def index
    @answers = generate_nested_hash(klass: Answer, by: current_user, params: @with_param, apply_filter: !is_admin?)
    cleared_pg_bonuses = Score.cleared_problem_group_bonuses(team_id: current_user&.team_id)

    @answers.each do |a|
      if score = a["score"]
        score["bonus_point"]    = cleared_pg_bonuses[score["id"]] || 0
        score["subtotal_point"] = score["point"] + score["bonus_point"]
      end
    end

    render json: @answers
  end

  # GET /answers/1
  def show
    @as_option = { include: {} }
    @as_option[:include][:score] = { methods: [:bonus_point, :subtotal_point] } if @with_param.include?("score")
    @answer = generate_nested_hash(klass: Answer, by: current_user, params: @with_param, id: params[:id], as_option: @as_option, apply_filter: !is_admin?)

    render json: @answer
  end

  # POST /answers
  def create
    @answer = Answer.new(answer_params)

    if @answer.save
      render json: @answer, status: :created, location: @answer
    else
      render json: @answer.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /answers/1
  def update
    if request.put? and not filled_all_attributes_of?(klass: Answer)
      status 400
      next json required: insufficient_attribute_names_of(klass: Answer)
    end

    @attrs = params_to_attributes_of(klass: Answer)
    @answer.attributes = @attrs

    if not @answer.valid?
      status 400
      next json @answer.errors
    end

    if @answer.save
      render json: @answer
    else
      # change to status: :unprocessable_entity
      render json: @answer.errors, status: :bad_request
    end

    if @answer.update(answer_params)
      render json: @answer
    else
      render json: @answer.errors, status: :unprocessable_entity
    end
  end

  # DELETE /answers/1
  def destroy
    if @answer.destroy
      render json: { status: "success" }, status: 204
    else
      render json: { status: "failed" }, status: 500
    end
  end

  private
    def all_before
      I18n.locale = :en if request.xhr?

      @with_param = (params[:with] || '').split(',') & Answer.allowed_nested_params(user: current_user) if request.get?
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_answer
      @answer = Answer.includes(:score).find(params[:id])
      halt 404 if not @answer&.allowed?(by: current_user, method: request.request_method)
    end

    # Only allow a trusted parameter "white list" through.
    def answer_params
      params.fetch(:answer, {})
    end
end
