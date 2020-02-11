# frozen_string_literal: true

# Slack通知のための汎用的なJob
# 外部サービスにアクセスする処理は
# ネットワークの遅延や相手サーバーダウンなどが原因で
# 長時間止まったり失敗したりする
# JobにするとAPIのレスポンスに影響しないしリトライが楽
class SlackNotifierJob < ApplicationJob
  queue_as :default

  def perform(message)
    return if Rails.application.config.slack_webhook_url.blank?

    notifier = Slack::Notifier.new(Rails.application.config.slack_webhook_url)
    notifier.ping(message)
  end
end
