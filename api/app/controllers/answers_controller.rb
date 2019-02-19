class AnswersController < ApplicationController
  before '/api/answers*' do
    I18n.locale = :en if request.xhr?

    halt 403 if !is_admin? && !is_writer? && !Config.in_competition_time?

    @with_param = (params[:with] || '').split(',') & Answer.allowed_nested_params(user: current_user) if request.get?
  end

  get '/api/answers' do
    @answers = generate_nested_hash(klass: Answer, by: current_user, params: @with_param, apply_filter: !is_admin?)
    cleared_pg_bonuses = Score.cleared_problem_group_bonuses(team_id: current_user&.team_id)

    @answers.each do |a|
      score = a['score']
      next if score.nil?

      score['bonus_point']    = cleared_pg_bonuses[score['id']] || 0
      score['subtotal_point'] = score['point'] + score['bonus_point']
    end

    json @answers
  end

  before '/api/answers/:id' do
    @answer = Answer.includes(:score).find_by(id: params[:id])

    halt 404 unless @answer&.allowed?(by: current_user, method: request.request_method)
  end

  get '/api/answers/:id' do
    @as_option = { include: {} }
    @as_option[:include][:score] = { methods: %i[bonus_point subtotal_point] } if @with_param.include?('score')
    @answer = generate_nested_hash(klass: Answer, by: current_user, params: @with_param, id: params[:id], as_option: @as_option, apply_filter: !is_admin?)

    json @answer
  end

  update_answer_block = proc do
    if request.put? and not filled_all_attributes_of?(klass: Answer)
      status 400
      next json required: insufficient_attribute_names_of(klass: Answer)
    end

    @attrs = params_to_attributes_of(klass: Answer)
    @answer.attributes = @attrs

    unless @answer.valid?
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

  put '/api/answers/:id', &update_answer_block
  patch '/api/answers/:id', &update_answer_block

  delete '/api/answers/:id' do
    if @answer.destroy
      status 204
      json status: 'success'
    else
      status 500
      json status: 'failed'
    end
  end

  before '/api/problems/:id/answers' do
    halt 403 if !is_admin? && !is_writer? && !Config.in_competition_time?

    @problem = Problem.find_by(id: params[:id])

    # Problemのフィルタも使うから注意
    pass if request.post? and @problem&.allowed?(by: current_user, method: 'GET') and Answer.allowed_to_create_by?(current_user)
    halt 404 unless @problem&.allowed?(by: current_user, method: request.request_method)
  end

  get '/api/problems/:id/answers' do
    @answers = Answer.readables(user: current_user)
      .where(problem: @problem)
    json @answers
  end

  post '/api/problems/:id/answers' do
    halt 403 unless Answer.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Answer)
    @attrs[:team_id] = current_user.team_id unless is_admin?
    @attrs[:problem_id] = @problem.id
    @answer = Answer.new(@attrs)

    if @answer.save
      push_notification(to: Role.where(name: %w(Admin Writer)), payload: @answer.notification_payload)

      status 201
      headers 'Location' => to("/api/answers/#{@answer.id}")
      json @answer
    else
      status 400
      json @answer.errors
    end
  end
end
