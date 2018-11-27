class NoticesController < ApplicationController
  before_action :before_all
  before_action :set_notice, only: [:show, :update, :destroy]

  # GET /notices
  def index
    @notices = generate_nested_hash(klass: Notice, by: current_user, params: @with_param, apply_filter: !is_admin?)
    render json: @notices
  end

  # GET /notices/1
  def show
    @notice = generate_nested_hash(klass: Notice, by: current_user, params: @with_param, id: params[:id].to_i, apply_filter: !is_admin?)
    render json: @notice
  end

  # POST /notices
  def create
    render status: 403 and return if not Notice.allowed_to_create_by?(current_user)

    @attrs = params_to_attributes_of(klass: Notice)
    @attrs[:member_id] = current_user.id if (not is_admin?) || @attrs[:member_id].nil?
    @notice = Notice.new(@attrs)

    if @notice.save
      headers "Location" => to("/api/notices/#{@notice.id}")
      push_notification(to: :everyone, payload: @notice.notification_payload)
      render json: @notice, status: :created, location: @notice
    else
      # render json: @notice.errors, status: :unprocessable_entity
      render json: @notice.errors, status: :bad_request
    end
  end

  # PATCH/PUT /notices/1
  def update
    if request.put? and not filled_all_attributes_of?(klass: Notice)
      render json: {required: insufficient_attribute_names_of(klass: Notice)}, status: :bad_request
      return
    end

    @attrs = params_to_attributes_of(klass: Notice)

    if (not is_admin?) && @attrs[:member_id] != nil && @attrs[:member_id].to_i != current_user&.id
      render json: member_id: "can't set to other member", status: 400
    end

    @notice.attributes = @attrs

    if not @notice.valid?
      render json: @notice.errors, status: 400
    end

    if @notice.save
      push_notification(to: :everyone, payload: @notice.notification_payload(state: :updated))
      render json: @notice
    else
      # render json: @notice.errors, status: :unprocessable_entity
      render json: @notice.errors, status: :bad_request
    end
  end

  # DELETE /notices/1
  def destroy
    if @notice.destroy
      render json: {status: "success"}, status: 204
    else
      render json: {status: "failed"}, status: 500
    end
  end

  private
    def before_all
      I18n.locale = :en if request.xhr?

      @with_param = (params[:with] || "").split(',') & Notice.allowed_nested_params(user: current_user) if request.get?
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_notice
      @notice = Notice.find(params[:id])
      halt 404 if not @notice&.allowed?(by: current_user, method: request.request_method)
    end

    # Only allow a trusted parameter "white list" through.
    def notice_params
      params.fetch(:notice, {})
    end
end
