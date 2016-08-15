require "sinatra/activerecord_helpers"
require "sinatra/json_helpers"
require_relative "../services/account_service"

class NotificationRoutes < Sinatra::Base
  helpers Sinatra::ActiveRecordHelpers
  helpers Sinatra::JSONHelpers
  helpers Sinatra::AccountServiceHelpers

  get "/api/notifications" do
    notifications = []
  	Problem.where("opened_at <= ?", DateTime.now)
  	       .order(:opened_at) \
           .map do |x|
              resource_info = {
                resource: "Problem",
                resource_id: x.id,
                sub_resource: nil,
                sub_resource_id: nil
              }

              notifications << resource_info.merge({
                type: "problem_opened",
                text: "問題が公開されました。",
                created_at: x.opened_at
              })

              if x.created_at != x.updated_at && x.opened_at < x.updated_at
                notifications << resource_info.merge({
                  type: "problem_updated",
                  text: "問題が更新されました。",
                  created_at: x.updated_at
                })
              end
            end

  	Comment.where(commentable_type: "Problem") \
  	       .order(:updated_at) \
           .map do |x|
              resource_info = {
                resource: "Comment",
                resource_id: x.id,
                sub_resource: x.commentable_type,
                sub_resource_id: x.commentable_id
              }

              notifications << resource_info.merge({
                type: "new_comment_to_problem",
                text: "問題の補足が公開されました。",
                created_at: x.created_at
              })

              if x.updated_at != x.created_at
                notifications << resource_info.merge({
                  type: "updated_comment_to_problem",
                  text: "問題の補足が更新されました。",
                  created_at: x.updated_at
                })
              end
            end

  	comments = Comment.where(commentable_type: "Issue") \
  	                  .joins("INNER JOIN issues ON issues.id = comments.commentable_id") \

    if current_user.team_id
    	comments = comments.where(issues: {team_id: current_user.team_id }) \
    end

  	comments.order(:updated_at) \
            .map do |x|
              resource_info = {
                resource: "Comment",
                resource_id: x.id,
                sub_resource: x.commentable_type,
                sub_resource_id: x.commentable_id
              }

              notifications << resource_info.merge({
                type: "created_comment_to_issue",
                text: "問題への質問が投稿されました。",
                created_at: x.created_at
              })

              if x.updated_at != x.created_at
                notifications << resource_info.merge({
                  type: "updated_comment_to_issue",
                  text: "問題への質問が編集されました。",
                  created_at: x.updated_at
                })
              end
            end

    json notifications.sort_by{|x| x[:created_at] }.reverse
  end
end
