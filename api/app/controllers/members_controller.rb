class MembersController < ApplicationController
  before_action :set_member, only: [:show, :update, :destroy]

  # GET /members
  def index
    @members = generate_nested_hash(klass: Member, by: current_user, params: @with_param, apply_filter: !is_admin?)

    render json: @members
  end

  # GET /members/1
  def show
    @member = generate_nested_hash(klass: Member, by: current_user, params: @with_param, id: params[:id], apply_filter: !is_admin?)
    render json: @member
  end

  # POST /members
  def create
    halt 403 if not Member.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Member, exclude: [:hashed_password], include: [:password])

    if !is_admin? && !is_writer?
      @team = Team.find_by_registration_code(params[:registration_code])
      if @team.nil?
        render json: {registration_code: ["を入力してください"]}, status: bad_request
        return
      end

      @attrs.delete(:registration_code)
      @attrs[:team_id] = @team.id
    end

    @attrs[:hashed_password] = hash_password(@attrs[:password])
    @attrs.delete(:password)
    @attrs[:role_id] ||= Role.find_by(name: "Participant").id

    @member = Member.new(@attrs)

    if not Role.permitted_to_create_by?(user: current_user, role_id: @member.role_id)
      halt 403
    end

    context = :create
    context = :sign_up if not logged_in?

    if @member.save(context: context)
      # headers "Location" => to("/api/members/#{@member.id}")
      # json @member, except: [:hashed_password]
      render json: @member, status: :created, location: @member
    else
      # render json: @member.errors, status: :unprocessable_entity
      render json: @member.errors, status: :bad_request
    end
  end

  # PATCH/PUT /members/1
  def update
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

    if not @member.valid?
      status 400
      next json @member.errors
    end

    if @member.save
      # json @member, except: [:hashed_password]
      render json: @member
    else
      # render json: @member.errors, status: :unprocessable_entity
      render json: @member.errors, status: :bad_request
    end

    if @member.update(member_params)
    else
    end
  end

  # DELETE /members/1
  def destroy
    if @member.destroy
      render json: {status: "success"}, status: 204
    else
      render json: {status: "failed"}, status: 500
    end
  end

  private
    def before_all
      I18n.locale = :en if request.xhr?

      @with_param = (params[:with] || "").split(',') & Member.allowed_nested_params(user: current_user) if request.get?

    end

    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find_by(id: params[:id])
      halt 404 if not @member&.allowed?(by: current_user, method: request.request_method)
    end

    # Only allow a trusted parameter "white list" through.
    def member_params
      params.fetch(:member, {})
    end
end
