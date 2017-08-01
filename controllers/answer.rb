require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"

class AnswerRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/api/answers*" do
    I18n.locale = :en if request.xhr?

    @with_param = (params[:with] || "").split(?,) & %w(score comments) if request.get?
  end

  get "/api/answers" do
    @answers = generate_nested_hash(klass: Answer, by: current_user, params: @with_param, apply_filter: !(is_admin? || is_viewer?))
    firstblood_ids = Score.firstbloods(only_ids: true)
    cleared_pg_ids = Score.cleared_problem_group_ids(team_id: current_user&.team_id)

    @answers.each do |a|
      if score = a["score"]
        score["is_firstblood"] = firstblood_ids.include? score["id"]

        bonus_point = 0
        bonus_point += (score["point"] * Setting.first_blood_bonus_percentage / 100.0).to_i if score["is_firstblood"]
        bonus_point += Setting.bonus_point_for_clear_problem_group if cleared_pg_ids.include? score["id"]

        score["bonus_point"]    = bonus_point
        score["subtotal_point"] = score["point"] + score["bonus_point"]
      end
    end

    json @answers
  end

  before "/api/answers/:id" do
    @answer = Answer.includes(:comments, :score) \
                    .find_by(id: params[:id])

    halt 404 if not @answer&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/answers/:id" do
    @as_option = { include: {} }
    @as_option[:include][:score] = { methods: [:is_firstblood, :bonus_point, :subtotal_point] } if @with_param.include?("score")
    @answer = generate_nested_hash(klass: Answer, by: current_user, params: @with_param, id: params[:id], as_option: @as_option, apply_filter: !(is_admin? || is_viewer?))

    json @answer
  end

  post "/api/answers" do
    halt 403 if not Answer.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Answer)
    @attrs[:team_id] = current_user.team_id if not is_admin?
    if %w(true 1).include? @attrs[:completed].to_s
      status 400
      next json completed: "can't be true on created"
    end

    @answer = Answer.new(@attrs)

    if @answer.save
      status 201
      headers "Location" => to("/api/answers/#{@answer.id}")
      json @answer
    else
      status 400
      json @answer.errors
    end
  end

  update_answer_block = Proc.new do
    if request.put? and not filled_all_attributes_of?(klass: Answer, exclude: [:completed_at])
      status 400
      next json required: insufficient_attribute_names_of(klass: Answer)
    end

    @attrs = params_to_attributes_of(klass: Answer)

    if "Participant" == current_user&.role&.name
      if @attrs.keys != [:completed]
        status 400
        next json @attrs.map{|k, v| [k, "participant can't edit"] }.to_h
      end

      # 参加者は completed を false にすることができない
      if %w(false 0).include? @attrs[:completed].to_s
        status 400
        next json completed: "participant can't make answer to not completed"
      end

      if @answer.comments.empty?
        status 400
        next json completed: "participant can't make answer with no comment completed"
      end

      # 参加者は同一の問題に対し、 Setting.answer_reply_delay_sec 秒以内に連続で採点依頼を送ることができない
      last_answer_completed_at = Answer.where(
          team_id: current_user&.team_id,
          problem_id: @answer.problem_id
        ) \
        .order(:completed_at) \
        .select(:completed_at) \
        .last.completed_at

      if last_answer_completed_at && DateTime.now <= (last_answer_completed_at + Setting.answer_reply_delay_sec.seconds)
        status 400
        next json completed: "participant can't make multiple answers of one problem completed within #{Setting.answer_reply_delay_sec} seconds"
      end
    end

    @attrs[:completed_at] = DateTime.now if !@answer.completed && @attrs[:completed]

    @answer.attributes = @attrs

    if not @answer.valid?
      status 400
      next json @answer.errors
    end

    if @answer.save
      json @answer
    else
      status 400
      json @answer.errors
    end
  end

  put "/api/answers/:id", &update_answer_block
  patch "/api/answers/:id", &update_answer_block

  delete "/api/answers/:id" do
    if @answer.destroy
      status 204
      json status: "success"
    else
      status 500
      json status: "failed"
    end
  end

  before "/api/problems/:id/answers" do
    @problem = Problem.find_by(id: params[:id])
    pass if request.post? and @problem&.allowed?(by: current_user, method: 'GET')
    halt 404 if not @problem&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/problems/:id/answers" do
    @answers = Answer.readables(user: current_user) \
                     .where(problem: @problem)
    json @answers
  end

  post "/api/problems/:id/answers" do
    halt 403 if not Answer.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Answer)
    @attrs[:team_id] = current_user.team_id if not is_admin?
    @attrs[:problem_id] = @problem.id
    @answer = Answer.new(@attrs)

    if @answer.save
      status 201
      headers "Location" => to("/api/answers/#{@answer.id}")
      json @answer
    else
      status 400
      json @answer.errors
    end
  end
end
