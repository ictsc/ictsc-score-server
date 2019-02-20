class NotificationsController < ApplicationController
  get '/api/notifications' do # rubocop:disable Metrics/BlockLength
    halt 404 if !is_admin? && !is_writer? && !Config.in_competition_time?

    notifications = []

    if Config.competition_start_at <= DateTime.now
      notifications << {
        resource: nil,
        resource_id: nil,
        type: 'competition_started',
        text: '競技が開始しました',
        created_at: Config.competition_start_at
      }
    end

    if Config.competition_end_at <= DateTime.now
      notifications << {
        resource: nil,
        resource_id: nil,
        type: 'competition_finished',
        text: '競技が終了しました',
        created_at: Config.competition_end_at
      }
    end

    Problem # rubocop:disable Metrics/BlockLength
      .readables(user: current_user)
      .includes(:comments, :answers)
      .each do |p|
        resource_info = {
          resource: 'Problem',
          resource_id: p.id,
          sub_resource: nil,
          sub_resource_id: nil
        }

        if p.created_at != p.updated_at
          notifications << resource_info.merge({
            type: 'problem_updated',
            text: '問題が更新されました。',
            created_at: p.updated_at
          })
        end

        p.comments.sort_by(&:updated_at).each do |c|
          resource_info = {
            resource: c.commentable_type,
            resource_id: c.commentable_id,
            sub_resource: 'Comment',
            sub_resource_id: c.id
          }

          notifications << resource_info.merge({
            type: 'new_comment_to_problem',
            text: '問題の補足が公開されました。',
            created_at: c.created_at
          })

          next if c.updated_at == c.created_at

          notifications << resource_info.merge({
            type: 'updated_comment_to_problem',
            text: '問題の補足が更新されました。',
            created_at: c.updated_at
          })
        end

        p.answers.sort_by(&:updated_at).each do |a|
          resource_info = {
            resource: 'Answer',
            resource_id: a.id
          }

          notifications << resource_info.merge({
            type: 'new_answer_to_problem',
            text: '解答が投稿されました。',
            created_at: a.created_at
          })
        end
      end

    comments = Comment.where(commentable_type: 'Issue')
      .joins('INNER JOIN issues ON issues.id = comments.commentable_id')

    if current_user&.team_id
      comments = comments.where(issues: { team_id: current_user.team_id })
    end

    comments
      .order(:updated_at)
      .each do |c|
        resource_info = {
          resource: c.commentable_type,
          resource_id: c.commentable_id,
          sub_resource: 'Comment',
          sub_resource_id: c.id
        }

        notifications << resource_info.merge({
          type: 'created_comment_to_issue',
          text: '問題への質問が投稿されました。',
          created_at: c.created_at
        })

        next if c.updated_at == c.created_at

        notifications << resource_info.merge({
          type: 'updated_comment_to_issue',
          text: '問題への質問が編集されました。',
          created_at: c.updated_at
        })
      end

    Score.readables(user: current_user).each do |s|
      resource_info = {
        resource: 'Score',
        resource_id: s.id,
        sub_resource: 'Answer',
        sub_resource_id: s.answer_id
      }

      notifications << resource_info.merge({
        type: 'new_score_to_answer',
        text: '解答への採点結果が公開されました。',
        created_at: s.updated_at
      })
    end

    filter_time_after = nil
    if params[:after]
      begin
        filter_time_after = DateTime.parse(params[:after])
      rescue # rubocop:disable Style/RescueStandardError
        halt 400
      end
    end

    notifications.reject! {|x| Config.competition_end_at < x[:created_at] } if is_participant?
    notifications.select! {|x| filter_time_after <= x[:created_at] } if filter_time_after

    json notifications.sort_by {|x| x[:created_at] }.reverse
  end
end
