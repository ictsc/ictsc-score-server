class MembersController < ApplicationController
  before '/api/members*' do
    I18n.locale = :en if request.xhr?

    @with_param = (params[:with] || '').split(',') & Member.allowed_nested_params(user: current_user) if request.get?
  end

  get '/api/members' do
    @members = generate_nested_hash(klass: Member, by: current_user, params: @with_param, apply_filter: !is_admin?)
    json @members
  end

  post '/api/members' do
    halt 404 unless Member.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Member, exclude: [:hashed_password], include: [:password])

    if !(is_admin? || is_writer?) || params[:registration_code].present?
      @team = Team.find_by(registration_code: params[:registration_code])
      if @team.nil?
        status 400
        next json registration_code: ['を入力してください']
      end

      @attrs.delete(:registration_code)
      @attrs[:team_id] = @team.id
    end

    @attrs[:role_id] ||= Role.participant!.id

    @member = Member.new(@attrs)

    unless Role.permitted_to_create_by?(user: current_user, role_id: @member.role_id)
      halt 404
    end

    if @member.save
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

    @member.attributes = params_to_attributes_of(klass: Member, **field_options)

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
