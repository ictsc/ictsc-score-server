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
        hash
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

  before "/member" do
    I18n.locale = :en if request.xhr?
  end

  post "/session" do
    halt 403 if logged_in?

    @member = Member.find_by(login: params[:login])

    if compare_password(params[:password], @member.hashed_password)
      login_as(@member.id)
      json status: "success"
    else
      json status: "failed"
    end
  end

  get "/session" do
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
      halt 402, { status: "failed"}.to_json
    end
  end

  get "/logout", &logout_block
  delete "/session", &logout_block

  get "/member/:id" do
    halt 404 if not Member.exists?(id: params[:id])
    json Member.find_by(id: params[:id]), except: [:hashed_password]
  end

  post "/member" do
    @attrs = attribute_values_of_class(Member, exclude: [:hashed_password], include: [:password])
    @attrs[:hashed_password] = crypt(@attrs[:password])
    @attrs.delete(:password)

    @member = Member.new(@attrs)

    if @member.save
      json @member, except: [:hashed_password]
    else
      json @member.errors
    end
  end

  update_member_block = Proc.new do
    halt 404 if not Member.exists?(id: params[:id])

    field_options = { exclude: [:hashed_password], include: [:password] }

    if request.put? and not satisfied_required_fields?(Member, field_options)
      halt 400, { required: insufficient_fields(Member, field_options) }.to_json
    end

    @member = Member.find_by(id: params[:id])
    @attrs = attribute_values_of_class(Member, field_options)

    if @attrs.key?(:password)
      @attrs[:hashed_password] = crypt(@attrs[:password])
      @attrs.delete(:password)
    end

    @member.attributes = @attrs

    if @member.save
      json @member, except: [:hashed_password]
    else
      json @member.errors
    end
  end

  put "/member/:id", &update_member_block
  patch "/member/:id", &update_member_block

  delete "/member/:id" do
    @member = Member.find_by(id: params[:id])
    halt 404 if @member.nil?

    if @member.destroy
      json status: "success"
    else
      json status: "failed"
    end
  end
end
