require 'sinatra/activerecord_helpers'
require 'sinatra/json_helpers'
require_relative '../services/account_service'
require_relative '../services/nested_entity'
require_relative '../services/notification_service'

class CommentRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::NestedEntityHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers
  helpers Sinatra::NotificationService

  # rubocop:disable Metrics/BlockLength
  # Issue 質問に対する解答
  # Problem 問題の補足
  [Issue, Problem].each do |klass|
    pluralize_name = klass.to_s.downcase.pluralize

    before "/api/#{pluralize_name}/:commentable_id/comments*" do
      I18n.locale = :en if request.xhr?

      @action = "#{pluralize_name}_comments"
      @commentable_id = params[:commentable_id]
      @commentable = klass.readables(user: current_user, action: @action)
        .find_by(id: @commentable_id)
      halt 404 if @commentable.nil?

      @with_param = (params[:with] || '').split(',') & Comment.allowed_nested_params(user: current_user) if request.get?
    end

    get "/api/#{pluralize_name}/:commentable_id/comments" do
      @comments = generate_nested_hash(klass: Comment, by: current_user, params: @with_param, action: @action, where: { commentable_id: @commentable_id }, apply_filter: !is_admin?)
      json @comments
    end

    before "/api/#{pluralize_name}/:commentable_id/comments/:comment_id" do
      @comment = Comment.find_by(id: params[:comment_id])
      halt 404 unless @comment&.allowed?(by: current_user, method: request.request_method, action: @action)
    end

    get "/api/#{pluralize_name}/:commentable_id/comments/:comment_id" do
      @comment = generate_nested_hash(klass: Comment, by: current_user, params: @with_param, id: params[:comment_id], action: @action, where: { commentable_id: @commentable_id }, apply_filter: !is_admin?)
      json @comment
    end

    post "/api/#{pluralize_name}/:commentable_id/comments" do
      halt 403 unless Comment.allowed_to_create_by?(current_user, action: @action)

      @attrs = params_to_attributes_of(klass: Comment)
      @attrs[:member_id] = current_user.id if (not is_admin?) || @attrs[:member_id].nil?
      @attrs[:commentable_type] = klass.to_s
      @attrs[:commentable_id] = @commentable_id
      @comment = Comment.new(@attrs)

      if @comment.save
        status 201
        headers 'Location' => to("/api/#{pluralize_name}/:commentable_id/comments/#{@comment.id}")

        case @commentable
        when Issue
          to =
            if is_participant? # Participant -> Admin / Writer
              Role.where(name: %w(Admin Writer))
            else               # Admin / Writer -> Participant
              @commentable.team
            end

          push_notification(to: to, payload: @comment.notification_payload)
        when Problem
          push_notification(to: @commentable.readable_teams, payload: @comment.notification_payload)
        end

        json @comment
      else
        status 400
        json @comment.errors
      end
    end

    update_comment_block = proc do
      if request.put? and not filled_all_attributes_of?(klass: Comment, exclude: %i[commentable_type commentable_id])
        status 400
        next json required: insufficient_attribute_names_of(klass: Comment)
      end

      @attrs = params_to_attributes_of(klass: Comment)
      @comment.attributes = @attrs

      unless @comment.valid?
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
        json status: 'success'
      else
        status 500
        json status: 'failed'
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
end
