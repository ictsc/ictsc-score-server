require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"
require_relative "../services/nested_entity"

class CommentRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  [Answer, Issue, Problem].each do |klass|
    pluralize_name = klass.to_s.downcase.pluralize
    before "/api/#{pluralize_name}/:commentable_id/comments*" do
      I18n.locale = :en if request.xhr?

      @action = "#{pluralize_name}_comments"
      @commentable_id = params[:commentable_id]
      @commentable = klass.readables(user: current_user, action: @action) \
                          .find_by(id: @commentable_id)
      halt 404 if @commentable.nil?

      @with_param = (params[:with] || "").split(?,) & %w(member) if request.get?
    end

    get "/api/#{pluralize_name}/:commentable_id/comments" do
      @comments = generate_nested_hash(klass: Comment, by: current_user, params: @with_param, action: @action, where: {commentable_id: @commentable_id}, apply_filter: !(is_admin? || is_viewer?))
      @comments.map do |c|
        c["member"]&.delete("hashed_password")
      end

      json @comments
    end

    before "/api/#{pluralize_name}/:commentable_id/comments/:comment_id" do
      @comment = Comment.find_by(id: params[:comment_id])
      halt 404 if not @comment&.allowed?(by: current_user, method: request.request_method, action: @action)
    end

    get "/api/#{pluralize_name}/:commentable_id/comments/:comment_id" do
      @comment = generate_nested_hash(klass: Comment, by: current_user, params: @with_param, id: params[:comment_id], action: @action, where: {commentable_id: @commentable_id}, apply_filter: !(is_admin? || is_viewer?))
      @comment["member"]&.delete("hashed_password")

      json @comment
    end

    post "/api/#{pluralize_name}/:commentable_id/comments" do
      halt 403 if not Comment.allowed_to_create_by?(current_user, action: @action)

      if klass == Answer
        if @commentable.completed && is_participant?
          status 400
          next json comment: "participant can't add comments to completed answer"
        end

        if @commentable.comments.count != 0
          status 400
          next json comment: "only one comment is allowed for an answer"
        end
      end

      @attrs = params_to_attributes_of(klass: Comment)
      @attrs[:member_id] = current_user.id if (not is_admin?) || @attrs[:member_id].nil?
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
      if request.put? and not filled_all_attributes_of?(klass: Comment, exclude: [:commentable_type, :commentable_id])
        status 400
        next json required: insufficient_attribute_names_of(klass: Comment)
      end

      if klass == Answer && @commentable.completed && is_participant?
        status 403
        next json comment: "participant can't edit comments of completed answer"
      end

      @attrs = params_to_attributes_of(klass: Comment)
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
