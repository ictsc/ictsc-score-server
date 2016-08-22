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
    @attachments = Attachment.accessible_resources(user_and_method)
    json @attachments
  end

  before "/api/attachments/:id" do
    @attachment = Attachment.accessible_resources(user_and_method) \
                            .find_by(id: params[:id])
    halt 404 if not @attachment
  end

  get "/api/attachments/:id" do
    json @attachment
  end

  post "/api/attachments" do
    halt 403 if not Attachment.allowed_to_create_by?(current_user)

    @attrs = attribute_values_of_class(Attachment)
    @attrs[:marker_id] = current_user.id
    @attachment = Attachment.new(@attrs)

    if not @attachment.save
      status 400
      json @attachment.errors
    else
      # save file
      f = params[:file]
      file_path = (Pathname(settings.root) + "/uploads/#{@attachment.id}/" + f[:filename]).to_s
      halt 400 unless file_path.start_with? (settings.root + "/uploads/")

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

    file_path = settings.root + "/uploads/#{params[:id]}/#{params[:filename]}"

    hash = Digest::SHA256.file(file_path).hexdigest
    if hash != params[:hash]
      halt 403
    end

    send_file file_path
  end
end
