class ProblemGroupsController < ApplicationController
  before_action :set_problem_group, only: [:show, :update, :destroy]

  # GET /problem_groups
  def index
    @problem_groups = ProblemGroup.all

    render json: @problem_groups
  end

  # GET /problem_groups/1
  def show
    render json: @problem_group
  end

  # POST /problem_groups
  def create
    @problem_group = ProblemGroup.new(problem_group_params)

    if @problem_group.save
      render json: @problem_group, status: :created, location: @problem_group
    else
      render json: @problem_group.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /problem_groups/1
  def update
    if @problem_group.update(problem_group_params)
      render json: @problem_group
    else
      render json: @problem_group.errors, status: :unprocessable_entity
    end
  end

  # DELETE /problem_groups/1
  def destroy
    @problem_group.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_problem_group
      @problem_group = ProblemGroup.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def problem_group_params
      params.fetch(:problem_group, {})
    end
end
