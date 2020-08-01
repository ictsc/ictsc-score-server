# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :require_login, only: %i[current logout]

  def current
    render json: build_current_team_response(current_team), status: :ok
  end

  def login
    team = Team.login(name: login_params[:name], password: login_params[:password])

    if team
      # protect session fixation attack
      reset_session

      # 以降のリクエストではこれからcurrent_teamをもとめる
      session[:team_id] = team.id

      # セッション管理用に記録する
      session[:created_at] = Time.current
      update_session_info

      # Bugsnagなどでのデバッグ用
      # ログイン後に更新される可能性があるので参考程度にする
      session[:team_name] = team.name
      session[:team_role] = team.role
      session[:channel] = team.channel

      render json: build_current_team_response(team), status: :ok
    else
      head :bad_request
    end
  end

  def logout
    reset_session
    head :no_content
  end

  private

  def login_params
    # wrap_parameter
    params.require(:session).permit(:name, :password)
  end

  # 必要な値だけ返す
  def build_current_team_response(team)
    # role: UI側で表示切り替えに使われる
    # channels: 非同期通知用チャンネル
    { id: team.id, role: team.role, channels: PlasmaPush.select_listen_channels(team: team) }
  end
end
