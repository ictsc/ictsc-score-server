require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

class CommentRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  before "/comment*" do
    I18n.locale = :en if request.xhr?
    require_login
  end

  get "/comment/:id" do
    halt 404 if not Comment.exists?(id: params[:id])
    json Comment.find_by(id: params[:id])
  end

  post "/comment" do
    @attrs = attribute_values_of_class(Comment)
    @attrs[:member_id] = current_user.id
    @comment = Comment.new(@attrs)

    if @comment.save
      json @comment
    else
      json @comment.errors
    end
  end

  update_comment_block = Proc.new do
    halt 404 if not Comment.exists?(id: params[:id])

    if request.put? and not satisfied_required_fields?(Comment)
      halt 400, { required: insufficient_fields(Comment) }.to_json
    end

    @comment = Comment.find_by(id: params[:id])
    @attrs = attribute_values_of_class(Comment)

    @comment.attributes = @attrs

    if @comment.save
      json @comment
    else
      json @comment.errors
    end
  end

  put "/comment/:id", &update_comment_block
  patch "/comment/:id", &update_comment_block

  delete "/comment/:id" do
    @comment = Comment.find_by(id: params[:id])
    halt 404 if @comment.nil?

    if @comment.destroy
      json status: "success"
    else
      json status: "failed"
    end
  end
end
