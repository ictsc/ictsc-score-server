require "open3"

require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"

class MemberRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
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
      salt_len = hash.index('$', 3)
      return false if salt_len.nil?
      salt = hash.slice(0, salt_len)

      return crypt(key, salt) == hash
    end

    def notification_channels
      {
        member: current_user&.notification_subscriber&.channel_id,
        role: current_user&.role&.notification_subscriber&.channel_id,
        team: current_user&.team&.notification_subscriber&.channel_id,
        all: "everyone"
      }.compact
    end
  end

  post "/api/session" do
    halt 403 if logged_in?

    if not Member.exists?(login: params[:login])
      status 401
      next json status: "failed"
    end

    @member = Member.find_by(login: params[:login])

    if compare_password(params[:password], @member.hashed_password)
      login_as(@member.id)
      status 201
      json status: "success", notification_channels: notification_channels, member: @member.as_json(except: [:hashed_password])
    else
      status 401
      json status: "failed"
    end
  end

  get "/api/session" do
    if logged_in?
      @with_param = (params[:with] || "").split(',') & %w(member member-team)
      @session = {
        logged_in: true,
        status: "logged_in",
        notification_channels: notification_channels
      }

      if not @with_param.empty?
        json_options = {
          except: [:hashed_password]
        }

        if @with_param.include? "member-team"
          json_options[:include] = { team: { except: [:registration_code] } }
        end

        @session[:member] = current_user.as_json(json_options)
      end

     json @session
    else
      json status: "not_logged_in", logged_in: false, notification_channels: notification_channels
    end
  end

  logout_block = Proc.new do
    if logged_in?
      logout
      json status: "success"
    else
      status 403
      json status: "failed"
    end
  end

  get "/api/logout", &logout_block
  delete "/api/session", &logout_block

  before "/api/members*" do
    I18n.locale = :en if request.xhr?

    @with_param = (params[:with] || "").split(',') & %w(team) if request.get?
  end

  get "/api/members" do
    @members = generate_nested_hash(klass: Member, by: current_user, params: @with_param, as_option: {except: [:hashed_password]}, apply_filter: !is_staff?)
    @members.each do |m|
      next if not m["team"]
      m["team"]["hashed_registration_code"] = Digest::SHA1.hexdigest(m["team"]["registration_code"])
      m["team"].delete("registration_code") if not %w(Admin Writer).include? current_user&.role&.name
    end
    json @members
  end

  before "/api/members/:id" do
    @member = Member.find_by(id: params[:id])
    halt 404 if not @member&.allowed?(by: current_user, method: request.request_method)
  end

  get "/api/members/:id" do
    @member = generate_nested_hash(klass: Member, by: current_user, params: @with_param, id: params[:id], as_option: {except: [:hashed_password]}, apply_filter: !is_staff?)
    if t = @member["team"]
      t["hashed_registration_code"] = Digest::SHA1.hexdigest(t["registration_code"])
      t.delete("registration_code") if not %w(Admin Writer).include? current_user&.role&.name
    end
    json @member
  end

  post "/api/members" do
    halt 403 if not Member.allowed_to_create_by?(current_user)

    @permit_role_ids = Role.readables(user: current_user).ids

    @attrs = params_to_attributes_of(klass: Member, exclude: [:hashed_password], include: [:password])

    # 未ログイン, admin, writerでないなら
    if current_user.nil? || !Role.where(name: ["Admin", "Writer"]).ids.include?(current_user.role_id)
      @team = Team.find_by(registration_code: params[:registration_code])
      if @team.nil?
        status 400
        next json registration_code: ["を入力してください"]
      end

      @attrs.delete(:registration_code)
      @attrs[:team_id] = @team.id
    end

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

    if current_user.nil? || !Role.where(name: ["Admin", "Writer"]).ids.include?(current_user.role_id)
      field_options[:exclude] << :team_id
      field_options[:exclude] << :role_id
    end

    if request.put? and not filled_all_attributes_of?(klass: Member, **field_options)
      status 400
      next json required: insufficient_attribute_names_of(klass: Member, **field_options)
    end

    @attrs = params_to_attributes_of(klass: Member, **field_options)

    if @attrs.key?(:password)
      @attrs[:hashed_password] = crypt(@attrs[:password])
      @attrs.delete(:password)
    end

    @member.attributes = @attrs

    if not @member.valid?
      status 400
      next json @member.errors
    end

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
