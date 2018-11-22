require "open3"

require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require "sinatra/crypt_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"

class MemberRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers
  helpers Sinatra::CryptHelpers

  helpers do
    def notification_channels
      {
        member: current_user&.notification_subscriber&.channel_id,
        role: current_user&.role&.notification_subscriber&.channel_id,
        team: current_user&.team&.notification_subscriber&.channel_id,
        all: "everyone"
      }.compact
    end
  end

  post "/api/session" do
    halt 403 if logged_in?

    if not Member.exists?(login: params[:login])
      status 401
      next json status: "failed"
    end

    @member = Member.find_by(login: params[:login])

    if compare_password(params[:password], @member.hashed_password)
      login_as(@member.id)
      status 201
      json status: "success", notification_channels: notification_channels, member: @member.as_json(except: [:hashed_password])
    else
      status 401
      json status: "failed"
    end
  end

  get "/api/session" do
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

     json @session
    else
      json status: "not_logged_in", logged_in: false, notification_channels: notification_channels
    end
  end

  logout_block = Proc.new do
    if logged_in?
      logout
      json status: "success"
    else
      status 403
      json status: "failed"
    end
  end
end
