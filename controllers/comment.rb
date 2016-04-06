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
    end

    get "/api/#{pluralize_name}/:commentable_id/comments" do
      json Comment.where(commentable_type: klass.to_s)
    end

    before "/api/#{pluralize_name}/:commentable_id/comments/:comment_id" do
      halt 404 if not Comment.exists?(id: params[:comment_id], commentable_type: klass.to_s)
      @comment = Comment.find_by(id: params[:comment_id], commentable_type: klass.to_s)

      if request.post? || request.put? || request.patch? || request.delete?
        halt 403 if (@comment.member_id != current_user.id) and (not current_user&.admin)
      end
    end

    get "/api/#{pluralize_name}/:commentable_id/comments/:comment_id" do
      json @comment
    end

    post "/api/#{pluralize_name}/:commentable_id/comments" do
      @attrs = attribute_values_of_class(Comment)
      @attrs[:member_id] = current_user.id
      @attrs[:commentable_type] = klass.to_s
      @attrs[:commentable_id] = params[:commentable_id]
      @comment = Comment.new(@attrs)

      if @comment.save
        status 201
        headers "Location" => to("/api/#{pluralize_name}/:commentable_id/comments/#{@comment.id}")
        json @comment
      else
        json @comment.errors
      end
    end

    update_comment_block = Proc.new do
      if request.put? and not satisfied_required_fields?(Comment)
        halt 400, { required: insufficient_fields(Comment) }.to_json
      end

      @attrs = attribute_values_of_class(Comment)
      @comment.attributes = @attrs

      halt 400, json(@comment.errors) if not @comment.valid?

      if @comment.save
        json @comment
      else
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
