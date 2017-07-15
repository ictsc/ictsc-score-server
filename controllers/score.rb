require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"

class ScoreRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/api/scores*" do
    I18n.locale = :en if request.xhr?

    @with_param = (params[:with] || "").split(?,) & %w(answer answer-problem) if request.get?
  end

  get "/api/scores" do
    @scores = generate_nested_hash(klass: Score, by: current_user, params: @with_param, apply_filter: !(is_admin? || is_viewer?))

    # NOTE: Calculate each Score#is_firstblood, Score#bonus_point, Score#subtotal_point is too slow
    # So, fetch firstblood problem ids first, and calculate each entities using it.
    # Entities are same as included in `GET "/api/scores/:id"`
    firstblood_ids = Score.firstbloods(only_ids: true)
    firstblood_bonuses = Answer \
      .joins(:problem, :score) \
      .where(scores: {id: firstblood_ids} ) \
      .select("scores.id, problems.perfect_point") \
      .pluck("scores.id, problems.perfect_point") \
      .inject(Hash.new(0)){|acc, (sid, perfect_point)| acc[sid] = perfect_point * (Setting.first_blood_bonus_percentage / 100.0); acc }


    # NOTE: Calculate each Score#cleared_problem_group? is too slow
    # So, doing same way doing upper (firstbloods).
    cleared_pg_ids = Score.cleared_problem_group_ids(team_id: current_user&.team_id)

    # @scores_array = @scores.as_json
    @scores.each do |s|
      s["is_firstblood"]  = firstblood_ids.include? s["id"]

      bonus_point = 0
      bonus_point += firstblood_bonuses[s["id"]] if s["is_firstblood"]
      bonus_point += Setting.bonus_point_for_clear_problem_group if cleared_pg_ids.include? s["id"]

      s["bonus_point"]    = bonus_point
      s["subtotal_point"] = s["point"] + s["bonus_point"]
    end

    json @scores
  end

  before "/api/scores/:id" do
    @score = Score.find_by(id: params[:id])
    halt 404 if not @score&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/scores/:id" do
    @as_option = { methods: [:is_firstblood, :bonus_point, :subtotal_point] }
    @score = generate_nested_hash(klass: Score, by: current_user, params: @with_param, id: params[:id], as_option: @as_option, apply_filter: !(is_admin? || is_viewer?))
    json @score #, { methods: [:is_firstblood, :bonus_point, :subtotal_point] }
  end

  post "/api/scores" do
    halt 403 if not Score.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Score)
    @attrs[:marker_id] = current_user.id if not is_admin?
    @score = Score.new(@attrs)

    if @score.save
      status 201
      headers "Location" => to("/api/scores/#{@score.id}")
      json @score
    else
      status 400
      json @score.errors
    end
  end

  update_score_block = Proc.new do
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
      json @score
    else
      status 400
      json @score.errors
    end
  end

  put "/api/scores/:id", &update_score_block
  patch "/api/scores/:id", &update_score_block

  delete "/api/scores/:id" do
    if @score.destroy
      status 204
      json status: "success"
    else
      status 500
      json status: "failed"
    end
  end

  before "/api/answers/:id/score" do
    @answer = Answer.find_by(id: params[:id])
    halt 404 if not @answer&.allowed?(by: current_user, method: "GET")
  end

  get "/api/answers/:id/score" do
    halt 404 if @answer.score.nil?
    @score = Score.find_by(id: @answer.score.id)
    halt 404 if not @score&.allowed?(by: current_user, method: request.request_method)

    status 303
    headers "Location" => to("/api/scores/#{@score.id}")
  end

  post "/api/answers/:id/score" do
    halt 403 if not Score.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Score)
    @attrs[:marker_id] = current_user.id if not is_admin?
    @attrs[:answer_id] = @answer.id
    @score = Score.new(@attrs)

    if @score.save
      status 201
      headers "Location" => to("/api/scores/#{@score.id}")
      json @score
    else
      status 400
      json @score.errors
    end
  end
end
