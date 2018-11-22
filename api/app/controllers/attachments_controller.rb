class AttachmentsController < ApplicationController
  before_action :before_all
  before_action :set_attachment, only: [:show, :update, :destroy]

  # GET /attachments
  def index
    @attachments = Attachment.readables(user: current_user)
    render json: @attachments
  end

  # GET /attachments/1
  # 情報のみ取得
  def show
    @attachment = Attachment.readables(user: current_user).find_by(id: params[:id])
    render json: @attachment
  end

  # POST /attachments
  def create
    halt 403 if not Attachment.allowed_to_create_by?(current_user)

    file = params[:file]
    halt 400 if file.blank?

    @attrs = params_to_attributes_of(klass: Attachment)
    @attrs[:member_id] = current_user.id if (not is_admin?) || @attrs[:member_id].nil?
    @attrs[:filename] = File.basename(file[:filename])
    @attrs[:access_token] = SecureRandom.hex(32)
    @attrs[:data] = file[:tempfile].read

    @attachment = Attachment.new(@attrs)

    if @attachment.save
      headers "Location" => to("/api/attachments/#{@attachment.id}")
      # dataが大きいとJSON化に失敗する
      # json @attachment, methods: [:url], except: [:data]
      render json: @attachment, status: :created, location: @attachment
    else
      # render json: @attachment.errors, status: :unprocessable_entity
      render json: @attachment.errors, status: :bad_request
    end
  end

  # PATCH/PUT /attachments/1
  def update
    if @attachment.update(attachment_params)
      render json: @attachment
    else
      render json: @attachment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /attachments/1
  def destroy
    if @attachment.destroy
      render json: {status: "success"}, status: 204
    else
      render json: {status: "failed"}, status: 500
    end
  end

  # ファイルを取得
  def download
  # get "/api/attachments/:id/:access_token" do
    # アクセス制限無し
    @attachment = Attachment.find_by(id: params[:id])

    halt 403 if @attachment.access_token != params[:access_token]

    send_attachment
  end

  private
    def before_all
      I18n.locale = :en if request.xhr?
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_attachment
      @attachment = Attachment.find(params[:id])
      halt 404 if not @attachment&.allowed?(by: current_user, method: request.request_method)
    end

    # Only allow a trusted parameter "white list" through.
    def attachment_params
      params.fetch(:attachment, {})
    end

    # Attachment#dataを送信する
    def send_attachment
      # Sinatraのsend_fileを参考
      filename = @attachment.filename

      if not response['Content-Type']
        content_type File.extname(filename), :default => 'application/octet-stream'
      end

      disposition = :attachment
      attachment(filename, disposition)
      headers['Content-Length'] = @attachment.data.bytesize

      @attachment.data
    end
end
