require 'digest/sha2'

# ファイルアップロード
class AttachmentsController < ApplicationController
  before '/api/attachments*' do
    I18n.locale = :en if request.xhr?
  end

  get '/api/attachments' do
    @attachments = Attachment.readables(user: current_user)
    json @attachments
  end

  post '/api/attachments' do
    halt 403 unless Attachment.allowed_to_create_by?(current_user)

    file = params[:file]
    halt 400 if file.blank?

    @attrs = params_to_attributes_of(klass: Attachment)
    @attrs[:member_id] = current_user.id if (not is_admin?) || @attrs[:member_id].nil?
    @attrs[:filename] = File.basename(file[:filename])
    @attrs[:access_token] = SecureRandom.hex(32)
    @attrs[:data] = file[:tempfile].read

    @attachment = Attachment.new(@attrs)

    if not @attachment.save
      status 400
      json @attachment.errors
    else
      status 201
      headers 'Location' => to("/api/attachments/#{@attachment.id}")
      # dataが大きいとJSON化に失敗する
      json @attachment, methods: [:url], except: [:data]
    end
  end

  before '/api/attachments/:id' do
    @attachment = Attachment.find_by(id: params[:id])
    halt 404 unless @attachment&.allowed?(by: current_user, method: request.request_method)
  end

  # IDからファイルの情報を取得
  get '/api/attachments/:id' do
    @attachment = Attachment.readables(user: current_user).find_by(id: params[:id])
    json @attachment
  end

  delete '/api/attachments/:id' do
    if @attachment.destroy
      status 204
      json status: 'success'
    else
      status 500
      json status: 'failed'
    end
  end

  # ファイルを取得
  get '/api/attachments/:id/:access_token' do
    # アクセス制限無し
    @attachment = Attachment.find_by(id: params[:id])

    halt 403 if @attachment.access_token != params[:access_token]

    send_attachment
  end

  # Attachment#dataを送信する
  def send_attachment
    # Sinatraのsend_fileを参考
    filename = @attachment.filename

    unless response['Content-Type']
      content_type File.extname(filename), default: 'application/octet-stream'
    end

    disposition = :attachment
    attachment(filename, disposition)
    headers['Content-Length'] = @attachment.data.bytesize

    @attachment.data
  end
end
