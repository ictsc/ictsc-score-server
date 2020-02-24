# frozen_string_literal: true

class AttachmentsController < ApplicationController
  before_action :require_login
  before_action :reject_audience, :validate_file, only: :create

  def show
    # tokenを知っているなら誰でも取得可能
    attachment = Attachment.find_by(token: params[:id])

    if attachment.nil?
      render json: "attachment(#{params[:id]}) not found", status: :not_found
      return
    end

    # 一応秘密情報を含むので途中ではキャッシュさせない
    # stale?の前に必要
    # https://api.rubyonrails.org/classes/ActionController/ConditionalGet.html
    expires_in 2.days, public: false
    return unless stale?(strong_etag: attachment.token_with_ext, last_modified: attachment.created_at)

    send_data(
      attachment.data,
      # filenameには間違えて問題コードを含んでしまうことが多いので代わりにtokenを返す
      filename: attachment.token_with_ext,
      # 画像だけinlineにする
      disposition: attachment.content_type.start_with?('image') ? 'inline' : 'attachment',
      type: attachment.content_type,
      stream: 'true',
      buffer_size: '4096'
    )
  end

  def create
    attachment = Attachment.new(
      filename: file.original_filename,
      data: file.read,
      content_type: file.content_type,
      size: file.size,
      team: current_team
    )

    if attachment.save
      render json: { url: attachment_path(attachment.token), type: attachment.content_type }, status: :ok
    else
      Rails.logger.error attachment.errors.full_messages
      render json: attachment.errors.messages, status: :bad_request
    end
  end

  private

  def file
    params.permit(:file)[:file]
  end

  def validate_file
    if file.blank?
      render json: '"file" field is required', status: :bad_request
    elsif !file.is_a?(ActionDispatch::Http::UploadedFile)
      render json: '"file" field accept only file', status: :bad_request
    elsif current_team.player? && 20.megabyte < file.size
      # サイズ制限(適当)
      render json: 'file size must be 20MB or less', status: :bad_request
    end
  end
end
