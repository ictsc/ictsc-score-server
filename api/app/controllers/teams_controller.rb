require 'sinatra/crypt_helpers'

class TeamsController < ApplicationController
  helpers Sinatra::CryptHelpers

  before '/api/teams*' do
    I18n.locale = :en if request.xhr?

    @with_param = (params[:with] || '').split(',') & Team.allowed_nested_params(user: current_user) if request.get?
  end

  get '/api/teams' do
    @teams = generate_nested_hash(klass: Team, by: current_user, params: @with_param, apply_filter: !is_admin?)

    if @with_param.include? 'answers-score'
      cleared_pg_bonuses = Score.cleared_problem_group_bonuses(team_id: current_user&.team_id)

      @teams.each do |t|
        t['answers']&.each do |a|
          s = a['score']
          next if s.nil?

          s['bonus_point']    = cleared_pg_bonuses[s['id']] || 0
          s['subtotal_point'] = s['point'] + s['bonus_point']
          a['score'] = s
        end
      end
    end

    json @teams
  end

  post '/api/teams' do
    halt 403 unless Team.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Team, exclude: [:hashed_registration_code], include: [:registration_code])

    @team = Team.new(@attrs)
    if @team.save
      status 201
      headers 'Location' => to("/api/teams/#{@team.id}")
      json @team
    else
      status 400
      json @team.errors
    end
  end

  before '/api/teams/:id' do
    @team = Team.find_by(id: params[:id])
    halt 404 unless @team&.allowed?(by: current_user, method: request.request_method)
  end

  get '/api/teams/:id' do
    @team = generate_nested_hash(klass: Team, by: current_user, params: @with_param, id: params[:id], apply_filter: !is_admin?)

    if @with_param.include? 'answers-score'
      cleared_pg_bonuses = Score.cleared_problem_group_bonuses(team_id: current_user&.team_id)

      @team['answers']&.each do |a|
        s = a['score']
        next if s.nil?

        s['bonus_point']    = cleared_pg_bonuses[s['id']] || 0
        s['subtotal_point'] = s['point'] + s['bonus_point']
        a['score'] = s
      end
    end

    json @team
  end

  update_team_block = proc do
    field_options = { exclude: [:hashed_registration_code], include: [:registration_code] }

    if request.put? and not filled_all_attributes_of?(klass: Team, **field_options)
      status 400
      next json required: insufficient_attribute_names_of(klass: Team, **field_options)
    end

    if @team.update(params_to_attributes_of(klass: Team, **field_options))
      json @team
    else
      status 400
      json @team.errors
    end
  end

  put '/api/teams/:id', &update_team_block
  patch '/api/teams/:id', &update_team_block

  delete '/api/teams/:id' do
    if @team.destroy
      status 204
      json status: 'success'
    else
      status 500
      json status: 'failed'
    end
  end
end
