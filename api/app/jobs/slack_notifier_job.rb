# frozen_string_literal: true

# TODO: 仮実装 あとで消す
class SlackNotifierJob < ApplicationJob
  queue_as :default

  def perform(mutation:, obj:)
    return if Rails.application.config.slack_webhook_url.blank?

    notice(build_message(mutation, obj))
  end

  def notice(message)
    notifier = Slack::Notifier.new(Rails.application.config.slack_webhook_url)
    notifier.ping(message)
  end

  def build_message(mutation, obj)
    case mutation
    when 'AddAnswer'
      mention = "<@#{obj.problem.writer}> " if obj.problem.writer.present?

      <<-MSG
        #{mention}解答が提出されました。
        問題: #{obj.problem.code}. #{obj.problem.body.title}
        チーム: #{obj.team.number}. #{obj.team.name}
      MSG
    when 'AddIssueComment'
      return if obj.from_staff

      issue = obj.issue
      problem = issue.problem
      mention = "<@#{problem.writer}> " if problem.writer.present?

      <<~MSG
        #{mention}質問コメントが追加されました。
        問題: #{problem.code}. #{problem.body.title}
        チーム: #{issue.team.number}. #{issue.team.name}
      MSG
    else
      "Slack通知未対応のミューテーションです #{mutation}"
    end
  end
end
