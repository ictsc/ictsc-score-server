require 'open3'
require_relative './application_controller'
require 'sinatra/crypt_helpers'

class MemberController < ApplicationController
  helpers Sinatra::CryptHelpers

  helpers do
    def notification_channels
      {
        member: current_user&.notification_subscriber&.channel_id,
        role: current_user&.role&.notification_subscriber&.channel_id,
        team: current_user&.team&.notification_subscriber&.channel_id,
        all: 'everyone'
      }.compact
    end
  end

  post '/api/session' do
    halt 403 if logged_in?

    unless Member.exists?(login: params[:login])
      status 401
      next json status: 'failed'
    end

    @member = Member.find_by(login: params[:login])

    if compare_password(params[:password], @member.hashed_password)
      login_as(@member.id)
      status 201
      json status: 'success', notification_channels: notification_channels, member: @member.as_json(except: [:hashed_password])
    else
      status 401
      json status: 'failed'
    end
  end

  get '/api/session' do
    if logged_in?
      # ここだけ @with_paramの扱いが特殊
      @with_param = (params[:with] || '').split(',') & %w(member member-team)

      @session = {
        logged_in: true,
        status: 'logged_in',
        notification_channels: notification_channels
      }

      unless @with_param.empty?
        json_options = {
          except: [:hashed_password]
        }

        if @with_param.include? 'member-team'
          json_options[:include] = { team: { except: [:registration_code] } }
        end

        @session[:member] = current_user.as_json(json_options)
      end

      json @session
    else
      json status: 'not_logged_in', logged_in: false, notification_channels: notification_channels
    end
  end

  logout_block = proc do
    if logged_in?
      logout
      json status: 'success'
    else
      status 403
      json status: 'failed'
    end
  end

  get '/api/logout', &logout_block
  delete '/api/session', &logout_block

  before '/api/members*' do
    I18n.locale = :en if request.xhr?

    @with_param = (params[:with] || '').split(',') & Member.allowed_nested_params(user: current_user) if request.get?
  end

  get '/api/members' do
    @members = generate_nested_hash(klass: Member, by: current_user, params: @with_param, apply_filter: !is_admin?)
    json @members
  end

  post '/api/members' do # rubocop:disable Metrics/BlockLength
    halt 403 unless Member.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Member, exclude: [:hashed_password], include: [:password])

    if !is_admin? && !is_writer?
      @team = Team.find_by_registration_code(params[:registration_code])
      if @team.nil?
        status 400
        next json registration_code: ['を入力してください']
      end

      @attrs.delete(:registration_code)
      @attrs[:team_id] = @team.id
    end

    @attrs[:hashed_password] = hash_password(@attrs[:password])
    @attrs.delete(:password)
    @attrs[:role_id] ||= Role.find_by(name: 'Participant').id

    @member = Member.new(@attrs)

    unless Role.permitted_to_create_by?(user: current_user, role_id: @member.role_id)
      halt 403
    end

    context = :create
    context = :sign_up unless logged_in?

    if @member.save(context: context)
      status 201
      headers 'Location' => to("/api/members/#{@member.id}")
      json @member, except: [:hashed_password]
    else
      status 400
      json @member.errors
    end
  end

  before '/api/members/:id' do
    @member = Member.find_by(id: params[:id])
    halt 404 unless @member&.allowed?(by: current_user, method: request.request_method)
  end

  get '/api/members/:id' do
    @member = generate_nested_hash(klass: Member, by: current_user, params: @with_param, id: params[:id], apply_filter: !is_admin?)
    json @member
  end

  update_member_block = proc do
    field_options = { exclude: [:hashed_password], include: [:password] }

    if !is_admin? && !is_writer?
      field_options[:exclude] << :team_id
      field_options[:exclude] << :role_id
    end

    if request.put? and not filled_all_attributes_of?(klass: Member, **field_options)
      status 400
      next json required: insufficient_attribute_names_of(klass: Member, **field_options)
    end

    @attrs = params_to_attributes_of(klass: Member, **field_options)

    if @attrs.key?(:password)
      @attrs[:hashed_password] = hash_password(@attrs[:password])
      @attrs.delete(:password)
    end

    @member.attributes = @attrs

    unless @member.valid?
      status 400
      next json @member.errors
    end

    if @member.save
      json @member, except: [:hashed_password]
    else
      status 400
      json @member.errors
    end
  end

  put '/api/members/:id', &update_member_block
  patch '/api/members/:id', &update_member_block

  delete '/api/members/:id' do
    if @member.destroy
      status 204
      json status: 'success'
    else
      status 500
      json status: 'failed'
    end
  end
end
