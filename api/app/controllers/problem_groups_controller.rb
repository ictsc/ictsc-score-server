class ProblemGroupsController < ApplicationController
  before_action :before_all
  before_action :set_problem_group, only: [:show, :update, :destroy]

  # GET /problem_groups
  def index
    @problem_groups = generate_nested_hash(klass: ProblemGroup, by: current_user, as_option: @as_option, params: @with_param, apply_filter: !is_admin?)
    render json: @problem_groups
  end

  # GET /problem_groups/1
  def show
    @problem_group = generate_nested_hash(klass: ProblemGroup, by: current_user, as_option: @as_option, params: @with_param, id: params[:id], apply_filter: !is_admin?)
    render json: @problem_group
  end

  # POST /problem_groups
  def create
    halt 403 if not ProblemGroup.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: ProblemGroup, include: [:problem_ids])

    begin
      @problem_group = ProblemGroup.new(@attrs)
    rescue ActiveRecord::RecordNotFound
      status 400
      next json problem_ids: "存在しないレコードです"
    end

    if @problem_group.save
      # headers "Location" => to("/api/problem_groups/#{@problem_group.id}")
      # json @problem_group.as_json(@as_option)
      render json: @problem_group, status: :created, location: @problem_group
    else
      # render json: @problem_group.errors, status: :unprocessable_entity
      render json: @problem_group.errors, status: :bad_request
    end
  end

  # PATCH/PUT /problem_groups/1
  def update
    if request.put? and not filled_all_attributes_of?(klass: ProblemGroup)
      status 400
      next json required: insufficient_attribute_names_of(klass: ProblemGroup)
    end

    @attrs = params_to_attributes_of(klass: ProblemGroup)
    @problem_group.attributes = @attrs

    if not @problem_group.valid?
      status 400
      next json @problem_group.errors
    end

    begin
      @problem_group.problem_ids = params[:problem_ids]
    rescue ActiveRecord::RecordNotFound
      status 400
      next json problem_ids: "存在しないレコードです"
    end

    if @problem_group.save
      # json @problem_group.as_json(@as_option)
      render json: @problem_group
    else
      # render json: @problem_group.errors, status: :unprocessable_entity
      render json: @problem_group.errors, status: :bad_request
    end
  end

  # DELETE /problem_groups/1
  def destroy
    if @problem_group.destroy
      render json: { status: 'success' }, status: 204
    else
      render json: { status: 'failed' }, status: 500
    end
  end

  private
    def before_all
      I18n.locale = :en if request.xhr?

      @with_param = (params[:with] || "").split(',') & ProblemGroup.allowed_nested_params(user: current_user) if request.get?
      @as_option = { methods: [:problem_ids] }
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_problem_group
      @problem_group = ProblemGroup.find(params[:id])
      halt 404 if not @problem_group&.allowed?(by: current_user, method: request.request_method)
    end

    # Only allow a trusted parameter "white list" through.
    def problem_group_params
      params.fetch(:problem_group, {})
    end
end
