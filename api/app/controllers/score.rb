class ScoreController < ApplicationController
  before '/api/scores*' do
    I18n.locale = :en if request.xhr?

    @with_param = (params[:with] || '').split(',') & Score.allowed_nested_params(user: current_user) if request.get?
  end

  get '/api/scores' do
    @scores = generate_nested_hash(klass: Score, by: current_user, params: @with_param, apply_filter: !is_admin?)

    # NOTE: Calculate each Score#cleared_problem_group? is too slow
    # So, fetch cleared problem ids first, and calculate each entities using it.
    cleared_pg_bonuses = Score.cleared_problem_group_bonuses(team_id: current_user&.team_id)

    # @scores_array = @scores.as_json
    @scores.each do |s|
      s['bonus_point']    = cleared_pg_bonuses[s['id']] || 0
      s['subtotal_point'] = s['point'] + s['bonus_point']
    end

    json @scores
  end

  before '/api/scores/:id' do
    @score = Score.find_by(id: params[:id])
    halt 404 unless @score&.allowed?(by: current_user, method: request.request_method)
  end

  get '/api/scores/:id' do
    @as_option = { methods: %i[bonus_point subtotal_point] }
    @score = generate_nested_hash(klass: Score, by: current_user, params: @with_param, id: params[:id], as_option: @as_option, apply_filter: !is_admin?)
    json @score # , { methods: [:bonus_point, :subtotal_point] }
  end

  update_score_block = proc do
    if request.put? and not filled_all_attributes_of?(klass: Score)
      status 400
      next json required: insufficient_attribute_names_of(klass: Score)
    end

    @attrs = params_to_attributes_of(klass: Score)
    @score.attributes = @attrs

    if @score.invalid?
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

  put '/api/scores/:id', &update_score_block
  patch '/api/scores/:id', &update_score_block

  delete '/api/scores/:id' do
    if @score.destroy
      status 204
      json status: 'success'
    else
      status 500
      json status: 'failed'
    end
  end

  before '/api/answers/:id/score' do
    @answer = Answer.find_by(id: params[:id])
    halt 404 unless @answer&.allowed?(by: current_user, method: 'GET')
  end

  get '/api/answers/:id/score' do
    halt 404 if @answer.score.nil?
    @score = Score.find_by(id: @answer.score.id)
    halt 404 unless @score&.allowed?(by: current_user, method: request.request_method)

    status 303
    headers 'Location' => to("/api/scores/#{@score.id}")
  end

  post '/api/answers/:id/score' do
    halt 403 unless Score.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Score)
    @attrs[:marker_id] = current_user.id if !is_admin? || @attrs[:marker_id].nil?
    @attrs[:answer_id] = @answer.id
    @score = Score.new(@attrs)

    if @score.save
      @answer = @score.answer
      notification_payload = @score.notification_payload
      push_notification(to: @answer.team, payload: notification_payload) if notification_payload.dig(:data, :notify_at) <= Setting.competition_end_at

      status 201
      headers 'Location' => to("/api/scores/#{@score.id}")
      json @score
    else
      status 400
      json @score.errors
    end
  end
end
