require "sinatra/base"
require_relative "../db/model"

module Sinatra
	module AccountServiceHelpers
		def require_login(*block)
			halt 401 unless logged_in?
		end

		def logged_in?
			return false if session[:member_id].nil?
			return Member.exists?(id: session[:member_id])
		end

		def current_user
			return nil if not logged_in?
			Member.find_by(id: session[:member_id])
		end

		def login_as(member_id)
			raise if not Member.exists?(id: member_id)
			session[:member_id] = member_id
		end

		def logout
			session.delete(:member_id)
		end
	end

	helpers AccountServiceHelpers
end
