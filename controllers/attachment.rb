require "digest/sha2"

require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

class AttachmentRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/api/attachments*" do
    I18n.locale = :en if request.xhr?
  end

  get "/api/attachments" do
    @attachments = Attachment.readables(user: current_user)
    json @attachments
  end

  before "/api/attachments/:id" do
    @attachment = Attachment.find_by(id: params[:id])
    halt 404 if not @attachment&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/attachments/:id" do
    json @attachment
  end

  post "/api/attachments" do
    halt 403 if not Attachment.allowed_to_create_by?(current_user)

    f = params[:file] || {}

    @attrs = attribute_values_of_class(Attachment)
    @attrs[:member_id] = current_user.id
    @attrs[:filename]  = f[:filename]
    @attachment = Attachment.new(@attrs)

    halt 400 if /(\/|\.\.)/ === f[:filename]

    if not @attachment.save
      status 400
      json @attachment.errors
    else
      # save file
      uploads_dir = Pathname(settings.root) + "../uploads/#{@attachment.id}/"
      file_path = (uploads_dir + f[:filename]).to_s
      Dir.mkdir uploads_dir.to_s
      halt 400 unless file_path.start_with? uploads_dir.to_s

      File.write(file_path, f[:tempfile].read)

      hash = Digest::SHA256.file(file_path).hexdigest

      status 201
      headers "Location" => to("/api/attachments/#{@attachment.id}")
      json @attachment.attributes.merge({"file_hash" => hash})
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

  get "/attachments/:id/:hash/:filename" do
    @attachment = Attachment.find_by(id: params[:id])

    if @attachment.filename != params[:filename]
      halt 404
    end

    begin
      uploads_dir = Pathname(settings.root) + "../uploads/#{@attachment.id}/"
      file_path = (uploads_dir + params[:filename]).to_s

      hash = Digest::SHA256.file(file_path).hexdigest
      if hash != params[:hash]
        halt 403
      end
    rescue
      halt 500
    end

    send_file file_path
  end
end
