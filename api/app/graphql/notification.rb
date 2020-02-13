# frozen_string_literal: true

# Slack通知とSSE通知を統括する
class Notification
  class << self
    def notify(mutation:, record:)
      slack_message = build_slack_message(mutation: mutation, record: record)
      SlackNotifierJob.perform_later(slack_message) if slack_message.present?

      PlasmaPush.push(**build_plasma_push_args(mutation: mutation, record: record))

      # 非同期通知が原因でリクエストが失敗しないようにする
    rescue StandardError => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
      Bugsnag.notify(e)
    end

    private

    def build_plasma_push_args(mutation:, record:)
      args = generate_plasma_push_args(mutation: mutation, record: record)
      construction_plasma_push_args(mutation: mutation, **args)
    end

    # 引数でkeyのバリデーションを軽くしている
    # JS様にkeyをcamelize
    def construction_plasma_push_args(mutation:, to:, title: nil, body: nil, problem_id: nil)
      {
        to: to,
        data: {
          # デスクトップ通知の重複防止
          uuid: SecureRandom.uuid,
          # リロードの判断基準
          mutation: mutation,
          problem_id: problem_id,
          # デスクトップ通知内容
          title: title,
          body: body
        }
          .compact
          .transform_keys {|key| key.to_s.camelize(:lower) }
      }
    end

    def generate_plasma_push_args(mutation:, record:) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      # audienceの自動リロードはおまけ程度

      case mutation
      when 'ApplyCategory', 'PinNotice', 'RegradeAnswers', 'UpdateConfig'
        { to: :everyone }
      when 'ApplyProblem'
        { to: :everyone, problem_id: record.id }
      when 'ApplyScore'
        # 遅延を考慮するとplayerに通知するのは手間なので一先ず無しで
        # なので採点によってスコアボードは自動で更新されない
        { to: %i[staff audience], problem_id: record.problem_id }
      when 'ApplyProblemEnvironment', 'StartIssue', 'TransitionIssueState'
        { to: [:staff, record.team], problem_id: record.problem_id }
      when 'ApplyTeam'
        { to: record.gte_roles }
      when 'ConfirmingAnswer'
        { to: :staff, problem_id: record.problem_id }
      when 'AddNotice'
        {
          to: record.target_team || :everyone,
          title: 'お知らせが追加されました',
          body: "#{record.title}\n#{record.text}"
        }
      when 'AddProblemSupplement'
        {
          to: record.problem.readable_players,
          problem_id: record.problem_id,
          title: '問題補足が追加されました',
          body: record.problem.body.title
        }
      when 'AddAnswer'
        {
          to: %i[staff audience],
          problem_id: record.problem_id,
          title: '解答が提出されました',
          body: record.problem.body.title
        }
      when 'AddIssueComment'
        for_staff = " - #{record.issue.team.name}"
        body = "#{record.issue.problem.body.title}#{record.from_staff ? nil : for_staff}\n#{record.text}"

        {
          to: record.from_staff ? record.issue.team : :staff,
          problem_id: record.issue.problem_id,
          title: record.from_staff ? '質問が投稿されました' : '質問に返答がありました',
          body: body
        }
      # when 'DeleteAttachment', 'DeleteCategory', 'DeleteProblem', 'DeleteProblemEnvironment', 'DeleteSession', 'DeleteNotice', 'DeleteProblemSupplement', 'DeleteIssueComment'
      else
        raise UnhandledClass, mutation.graphql_name
      end
    end

    # Slack通知用のメッセージを作る
    # Slack通知しない場合はnilを返す
    def build_slack_message(mutation:, record:)
      # TODO: mentionの解決をここで行う?
      #       redisにリストを持っておいてhogehoge
      #       SlackのAPIにリクエスト送るならJobにしたい

      case mutation
      when 'AddAnswer'
        mention = "<@#{record.problem.writer}> " if record.problem.writer.present?

        <<-MSG
          #{mention}解答提出
          問題: #{record.problem.code} - #{record.problem.body.title}
          チーム: No#{record.team.number} - #{record.team.name}
        MSG
      when 'AddIssueComment'
        return if record.from_staff

        issue = record.issue
        problem = issue.problem
        mention = "<@#{problem.writer}> " if problem.writer.present?

        <<~MSG
          #{mention}質問追加
          問題: #{problem.code} - #{problem.body.title}
          チーム: No#{issue.team.number} - #{issue.team.name}
        MSG
      else
        nil
      end
    end
  end
end
