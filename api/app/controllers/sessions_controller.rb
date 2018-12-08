class SessionsController < ApplicationController
  before_action :set_session, only: [:show, :update, :destroy]

  # GET /sessions/1
  def show
    if logged_in?
      # ここだけ @with_paramの扱いが特殊
      @with_param = (params[:with] || "").split(',') & %w(member member-team)

      @session = {
        logged_in: true,
        status: "logged_in",
        notification_channels: notification_channels
      }

      if not @with_param.empty?
        json_options = {
          except: [:hashed_password]
        }

        if @with_param.include? "member-team"
          json_options[:include] = { team: { except: [:registration_code] } }
        end

        @session[:member] = current_user.as_json(json_options)
      end

      render json: @session
    else
      render json: { status: "not_logged_in", logged_in: false, notification_channels: notification_channels }
    end
  end

  # POST /sessions
  def create
    render status: 403 and return if logged_in?

    if not Member.exists?(login: params[:login])
      render json: {status: "failed"}, status: 401
      return
    end

    @member = Member.find_by(login: params[:login])

    if compare_password(params[:password], @member.hashed_password)
      login_as(@member.id)
      render json: {status: "success", notification_channels: notification_channels, member: @member.as_json(except: [:hashed_password])}, status: 201
    else
      render json: {status: "failed"}, status: 401
    end
  end

  # DELETE /sessions/1
  def destroy
    if logged_in?
      logout
      render json: {status: "success"}
    else
      render json: {status: "failed"}, status: 403
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_session
      @session = Session.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def session_params
      params.fetch(:session, {})
    end

    def notification_channels
      {
        member: current_user&.notification_subscriber&.channel_id,
        role: current_user&.role&.notification_subscriber&.channel_id,
        team: current_user&.team&.notification_subscriber&.channel_id,
        all: "everyone"
      }.compact
    end
end
