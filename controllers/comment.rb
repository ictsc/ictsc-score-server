require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

class CommentRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  [Answer, Issue, Problem].each do |klass|
    pluralize_name = klass.to_s.downcase.pluralize
    before "/api/#{pluralize_name}/:commentable_id/comments*" do
      I18n.locale = :en if request.xhr?
      require_login

      @action = "#{pluralize_name}_comments"
      @commentable_id = params[:commentable_id]
      @commentable = klass.readables(user: current_user, action: @action) \
                          .find(@commentable_id)
      halt 404 if @commentable.nil?
    end

    get "/api/#{pluralize_name}/:commentable_id/comments" do
      json Comment.readables(user: current_user, action: @action) \
                  .where(commentable_id: params[:commentable_id].to_i)
    end

    before "/api/#{pluralize_name}/:commentable_id/comments/:comment_id" do
      @comment = Comment.find_by(id: params[:comment_id])
      halt 404 if not @comment&.allowed?(by: current_user, method: request.request_method, action: @action)
    end

    get "/api/#{pluralize_name}/:commentable_id/comments/:comment_id" do
      json @comment
    end

    post "/api/#{pluralize_name}/:commentable_id/comments" do
      halt 403 if not Comment.allowed_to_create_by?(current_user, action: @action)

      @attrs = attribute_values_of_class(Comment)
      @attrs[:member_id] = current_user.id
      @attrs[:commentable_type] = klass.to_s
      @attrs[:commentable_id] = @commentable_id
      @comment = Comment.new(@attrs)

      if @comment.save
        status 201
        headers "Location" => to("/api/#{pluralize_name}/:commentable_id/comments/#{@comment.id}")
        json @comment
      else
        status 400
        json @comment.errors
      end
    end

    update_comment_block = Proc.new do
      if request.put? and not satisfied_required_fields?(Comment)
        status 400
        next json required: insufficient_fields(Comment)
      end

      @attrs = attribute_values_of_class(Comment)
      @comment.attributes = @attrs

      if not @comment.valid?
        status 400
        next json @comment.errors
      end

      if @comment.save
        json @comment
      else
        status 400
        json @comment.errors
      end
    end

    put "/api/#{pluralize_name}/:commentable_id/comments/:comment_id", &update_comment_block
    patch "/api/#{pluralize_name}/:commentable_id/comments/:comment_id", &update_comment_block

    delete "/api/#{pluralize_name}/:commentable_id/comments/:comment_id" do
      if @comment.destroy
        status 204
        json status: "success"
      else
        status 500
        json status: "failed"
      end
    end
  end
end
