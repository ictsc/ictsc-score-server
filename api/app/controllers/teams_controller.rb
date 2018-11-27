class TeamsController < ApplicationController
  before_action :before_all
  before_action :set_team, only: [:show, :update, :destroy]

  # GET /teams
  def index
    @teams = generate_nested_hash(klass: Team, by: current_user, params: @with_param, apply_filter: !is_admin?)

    if @with_param.include? "answers-score"
      cleared_pg_bonuses = Score.cleared_problem_group_bonuses(team_id: current_user&.team_id)

      @teams.each do |t|
        t["answers"]&.each do |a|
          if s = a["score"]
            s["bonus_point"]    = cleared_pg_bonuses[s["id"]] || 0
            s["subtotal_point"] = s["point"] + s["bonus_point"]

            a["score"] = s
          end
        end
      end
    end

    render json: @teams
  end

  # GET /teams/1
  def show
    @team = generate_nested_hash(klass: Team, by: current_user, params: @with_param, id: params[:id], apply_filter: !is_admin?)

    if @with_param.include? "answers-score"
      cleared_pg_bonuses = Score.cleared_problem_group_bonuses(team_id: current_user&.team_id)

      @team["answers"]&.each do |a|
        if s = a["score"]
          s["bonus_point"]    = cleared_pg_bonuses[s["id"]] || 0
          s["subtotal_point"] = s["point"] + s["bonus_point"]

          a["score"] = s
        end
      end
    end

    render json: @team
  end

  # POST /teams
  def create
    halt 403 if not Team.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Team, exclude: [:hashed_registration_code], include: [:registration_code])

    @attrs[:hashed_registration_code] = hash_password(@attrs[:registration_code])
    @attrs.delete(:registration_code)

    @team = Team.new(@attrs)
    if @team.save
      status 201
      headers "Location" => to("/api/teams/#{@team.id}")
      json @team
      render json: @team, status: :created, location: @team
    else
      # render json: @team.errors, status: :unprocessable_entity
      render json: @team.errors, status: :bad_request
    end
  end

  # PATCH/PUT /teams/1
  def update
    field_options = { exclude: [:hashed_registration_code], include: [:registration_code] }

    if request.put? and not filled_all_attributes_of?(klass: Team, **field_options)
      render json: { required: insufficient_attribute_names_of(klass: Team, **field_options) }, status: 400
      return
    end

    @attrs = params_to_attributes_of(klass: Team)

    if @attrs.key?(:registration_code)
      @attrs[:hashed_registration_code] = hash_password(@attrs[:registration_code])
      @attrs.delete(:registration_code)
    end

    @team.attributes = @attrs

    if not @team.valid?
      render json: @team.errors, status: 400
      return
    end

    if @team.save
      render json: @team
    else
      # render json: @team.errors, status: :unprocessable_entity
      render json: @team.errors, status: :bad_request
    end
  end

  # DELETE /teams/1
  def destroy
    if @team.destroy
      render json: {status: "success"}, status: 204
    else
      render json: {status: "failed"}, status: 500
    end
  end

  private
    def before_all
      I18n.locale = :en if request.xhr?

      @with_param = (params[:with] || "").split(',') & Team.allowed_nested_params(user: current_user) if request.get?
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_team
      @team = Team.find(params[:id])
      halt 404 if not @team&.allowed?(by: current_user, method: request.request_method)
    end

    # Only allow a trusted parameter "white list" through.
    def team_params
      params.fetch(:team, {})
    end
end
