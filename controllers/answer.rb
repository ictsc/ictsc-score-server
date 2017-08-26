require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"
require_relative "../services/notification_service"

class AnswerRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers
  helpers Sinatra::NotificationService

  before "/api/answers*" do
    I18n.locale = :en if request.xhr?

    @with_param = (params[:with] || "").split(?,) & %w(score) if request.get?
  end

  get "/api/answers" do
    @answers = generate_nested_hash(klass: Answer, by: current_user, params: @with_param, apply_filter: !(is_admin? || is_viewer?))
    cleared_pg_bonuses = Score.cleared_problem_group_bonuses(team_id: current_user&.team_id)

    @answers.each do |a|
      if score = a["score"]
        score["bonus_point"]    = cleared_pg_bonuses[s["id"]] || 0
        score["subtotal_point"] = score["point"] + score["bonus_point"]
      end
    end

    json @answers
  end

  before "/api/answers/:id" do
    @answer = Answer.includes(:score).find_by(id: params[:id])

    halt 404 if not @answer&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/answers/:id" do
    @as_option = { include: {} }
    @as_option[:include][:score] = { methods: [:bonus_point, :subtotal_point] } if @with_param.include?("score")
    @answer = generate_nested_hash(klass: Answer, by: current_user, params: @with_param, id: params[:id], as_option: @as_option, apply_filter: !(is_admin? || is_viewer?))

    json @answer
  end

  post "/api/answers" do
    halt 403 if not Answer.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Answer)
    @attrs[:team_id] = current_user.team_id if not is_admin?

    @answer = Answer.new(@attrs)

    # # 参加者は同一の問題に対し、 Setting.answer_reply_delay_sec 秒以内に連続で採点依頼を送ることができない
    last_answer_created_at = Answer.where(
        team_id: current_user&.team_id,
        problem_id: @answer.problem_id
      ).maximum(:created_at)

    if last_answer_created_at && DateTime.now <= (last_answer_created_at + Setting.answer_reply_delay_sec.seconds)
      status 400
      next json answer: "participant can't submit multiple answers to one problem within #{Setting.answer_reply_delay_sec} seconds"
    end

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
      push_notification(to: Role.where(name: %w(Admin Writer)), payload: @answer.notification_payload)

      status 201
      headers "Location" => to("/api/answers/#{@answer.id}")
      json @answer
    else
      status 400
      json @answer.errors
    end
  end
end
