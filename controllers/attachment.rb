require "digest/sha2"

require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

# ファイルアップロード
class AttachmentRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  def uploads_dir
    @uploads_dir ||= Pathname(settings.root) + "../uploads/#{@attachment.id}/"
  end

  def file_path
    @file_path ||= (uploads_dir + @file_name).to_s
  end

  def file_hash
    @file_hash ||= Digest::SHA256.file(file_path).hexdigest
  end

  before "/api/attachments*" do
    I18n.locale = :en if request.xhr?
  end

  get "/api/attachments" do
    @attachments = Attachment.readables(user: current_user)
    json @attachments
  end

  # 権限チェック
  before "/api/attachments/:id" do
    @attachment = Attachment.find_by(id: params[:id])
    halt 404 if not @attachment&.allowed?(by: current_user, method: request.request_method)
  end

  # IDからファイルの情報を取得
  get "/api/attachments/:id" do
    json @attachment
  end

  post "/api/attachments" do
    halt 403 if not Attachment.allowed_to_create_by?(current_user)

    f = params[:file] || {}

    @attrs = params_to_attributes_of(klass: Attachment)
    @attrs[:member_id] = current_user.id if (not is_admin?) || @attrs[:member_id].nil?
    @attrs[:filename]  = f[:filename]
    @attachment = Attachment.new(@attrs)
    @file_name = f[:filename]

    halt 400 if /(\/|\.\.)/ === f[:filename]

    if not @attachment.save
      status 400
      json @attachment.errors
    else
      # save file
      FileUtils.mkdir_p uploads_dir.to_s
      halt 400 unless file_path.start_with? uploads_dir.to_s

      File.write(file_path, f[:tempfile].read)

      # ファイルのハッシュを返す
      status 201
      headers "Location" => to("/api/attachments/#{@attachment.id}")
      json @attachment.attributes.merge({"file_hash" => file_hash})
    end
  end

  delete "/api/attachments/:id" do
    if @attachment.destroy
      status 204
      json status: "success"
    else
      status 500
      json status: "failed"
    end
  end

  # ファイルを取得
  # ファイルのハッシュが無いと取得できない
  get "/attachments/:id/:hash/:filename" do
    @attachment = Attachment.find_by(id: params[:id])
    @file_name = params[:filename]

    if @attachment.filename != params[:filename]
      halt 404
    end

    begin
      if file_hash != params[:hash]
        halt 403
      end
    rescue
      halt 500
    end

    send_file file_path
  end
end
