# frozen_string_literal: true

class AttachmentsController < ApplicationController
  before_action :require_login

  def show
    # tokenを知っているなら誰でも取得可能
    attachment = Attachment.find_by(token: params[:id])

    # filenameには間違えて問題コードを含んでしまうことが多いので代わりにtokenを返す
    send_data(
      attachment.data,
      filename: attachment.token,
      type: attachment.content_type,
      disposition: 'inline',
      stream: 'true',
      buffer_size: '4096'
    )
  end

  def create
    file = file_params[:file]

    if current_team.audience?
      head :forbidden
      return
    end

    if file.blank?
      head :bad_request
      return
    end

    attachment = Attachment.new(
      filename: file.original_filename,
      data: file.read,
      content_type: file.content_type,
      team: current_team
    )

    if attachment.save
      render json: attachment_path(attachment.token), status: :ok
    else
      render json: attachment.errors.messages, status: :bad_request
    end
  end

  private

  def file_params
    params.permit(:file)
  end
end
