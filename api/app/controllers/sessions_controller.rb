class SessionsController < ApplicationController
  get '/api/session' do
    next json status: 'not_logged_in', logged_in: false, notification_channels: notification_channels unless logged_in?

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
  end

  post '/api/session' do
    halt 404 if logged_in?

    unless Member.exists?(login: params[:login])
      status 401
      next json status: 'failed'
    end

    @member = Member.find_by(login: params[:login])

    if @member.same_password?(params[:password])
      login_as(@member.id)
      status 201
      json status: 'success', notification_channels: notification_channels, member: @member.as_json(except: [:hashed_password])
    else
      status 401
      json status: 'failed'
    end
  end

  logout_block = proc do
    if logged_in?
      logout
      json status: 'success'
    else
      status 404
      json status: 'failed'
    end
  end

  get '/api/logout', &logout_block
  delete '/api/session', &logout_block

  def notification_channels
    {
      member: current_user&.notification_subscriber&.channel_id,
      role: current_user&.role&.notification_subscriber&.channel_id,
      team: current_user&.team&.notification_subscriber&.channel_id,
      all: 'everyone'
    }.compact
  end
end
