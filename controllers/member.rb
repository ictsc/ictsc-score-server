require "open3"

require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

class MemberRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  helpers do
    def crypt(key, salt = "")
      return nil unless key.is_a? String

      crypt_binname = case RUBY_PLATFORM
        when /darwin/;  "crypt_darwin_amd64"
        when /freebsd/; "crypt_freebsd_amd64"
        when /linux/;   "crypt_linux_amd64"
      end
      path = File.join(settings.root, "../ext", crypt_binname)
      hash, status = Open3.capture2(path, key, salt)
      if status.exitstatus.zero?
        hash.strip
      else
        nil
      end
    end

    def compare_password(key, hash)
      salt_len = hash.index(?$, 3)
      return false if salt_len.nil?
      salt = hash.slice(0, salt_len)

      return crypt(key, salt) == hash
    end
  end

  get "/api/login_as" do
    @member = Member.find_by(id: params[:id])

    if @member
      login_as(@member.id)
      json status: "success"
    else
      json status: "failed"
    end
  end

  post "/api/session" do
    halt 403 if logged_in?

    halt 401 if not Member.exists?(login: params[:login])
    @member = Member.find_by(login: params[:login])

    if compare_password(params[:password], @member.hashed_password)
      login_as(@member.id)
      json status: "success"
    else
      json status: "failed"
    end
  end

  get "/api/session" do
    if logged_in?
      json status: "logged_in", member_id: current_user.id
    else
      json status: "not_logged_in"
    end
  end

  logout_block = Proc.new do
    if logged_in?
      logout
      json status: "success"
    else
      halt 403, { status: "failed"}.to_json
    end
  end

  get "/api/logout", &logout_block
  delete "/api/session", &logout_block

  before "/api/members*" do
    I18n.locale = :en if request.xhr?
  end

  get "/api/members" do
    @members = Member.accessible_resources(user_and_method)
    json @members, except: [:hashed_password]
  end

  before "/api/members/:id" do
    @member = Member.accessible_resources(user_and_method) \
                    .find_by(id: params[:id])
    halt 404 if not @member
  end

  get "/api/members/:id" do
    json @member, except: [:hashed_password]
  end

  post "/api/members" do
    halt 403 if not Member.allowed_to_create_by?(current_user)

    @permit_role_ids = Role.accessible_resources(user: current_user, method: "GET").ids

    @attrs = attribute_values_of_class(Member, exclude: [:hashed_password], include: [:password])
    @attrs[:hashed_password] = crypt(@attrs[:password])
    @attrs.delete(:password)
    @attrs[:role_id] ||= Role.find_by(name: "Participant").id

    @member = Member.new(@attrs)

    if not @permit_role_ids.include? @member.role_id
      halt 403
    end


    context = :create
    context = :sign_up if not logged_in?

    if @member.save(context: context)
      status 201
      headers "Location" => to("/api/members/#{@member.id}")
      json @member, except: [:hashed_password]
    else
      status 400
      json @member.errors
    end
  end

  update_member_block = Proc.new do
    field_options = { exclude: [:hashed_password], include: [:password] }

    if request.put? and not satisfied_required_fields?(Member, field_options)
      halt 400, { required: insufficient_fields(Member, field_options) }.to_json
    end

    @attrs = attribute_values_of_class(Member, field_options)

    if @attrs.key?(:password)
      @attrs[:hashed_password] = crypt(@attrs[:password])
      @attrs.delete(:password)
    end

    @member.attributes = @attrs

    halt 400, json(@member.errors) if not @member.valid?

    if @member.save
      json @member, except: [:hashed_password]
    else
      status 400
      json @member.errors
    end
  end

  put "/api/members/:id", &update_member_block
  patch "/api/members/:id", &update_member_block

  delete "/api/members/:id" do
    if @member.destroy
      status 204
      json status: "success"
    else
      status 500
      json status: "failed"
    end
  end
end
