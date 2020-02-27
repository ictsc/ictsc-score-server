# frozen_string_literal: true

# Slack通知とSSE通知を統括する
class Notification
  class << self
    def notify(mutation:, record:)
      send_plasma_notification(mutation: mutation, record: record)
      Rails.logger.debug { "Notification published #{mutation}".green }

      slack_message = build_slack_message(mutation: mutation, record: record)
      SlackNotifierJob.perform_later(slack_message) if slack_message.present?

      # 非同期通知が原因でリクエストが失敗しないようにする
    rescue StandardError => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
      Bugsnag.notify(e)
    end

    private

    def send_plasma_notification(mutation:, record:)
      args_list = Array.wrap(generate_plasma_push_args(mutation: mutation, record: record))
      args_list.each do |args|
        PlasmaPush.push(**construction_plasma_push_args(mutation: mutation, **args))
      end
    end

    # 引数でkeyのバリデーションを軽くしている
    # JS様にkeyをcamelize
    def construction_plasma_push_args(mutation:, to:, title: nil, body: nil, problem_id: nil, options: {})
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
          body: body,
          options: options
            .compact
            .transform_keys {|key| key.to_s.camelize(:lower) }
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
      when 'ApplyProblemEnvironment', 'TransitionIssueState'
        { to: [:staff, record.team || :player], problem_id: record.problem_id }
      when 'ApplyTeam'
        { to: record.gte_roles }
      when 'ConfirmingAnswer'
        { to: :staff, problem_id: record.problem_id }
      when 'AddNotice'
        [
          {
            to: :staff
            # title: 'お知らせが追加されました',
            # body: "#{record.title}\n#{record.text}"
          },
          {
            to: record.target_team || %i[audience player],
            title: 'お知らせが追加されました',
            body: "#{record.title}\n#{record.text}"
          }
        ]
      when 'AddProblemSupplement'
        [
          {
            to: %i[staff audience],
            problem_id: record.problem_id
          },
          {
            to: record.problem.readable_players,
            problem_id: record.problem_id,
            title: '問題補足が追加されました',
            body: record.problem.body.title
          }
        ]
      when 'AddAnswer'
        [
          {
            to: :staff,
            problem_id: record.problem_id,
            title: '解答が提出されました',
            body: build_team_and_problem_summary(team: record.team, problem: record.problem)
          },
          {
            to: %i[audience player],
            problem_id: record.problem_id
          }
        ]
      when 'AddPenalty'
        [
          {
            to: :staff,
            problem_id: record.problem_id,
            title: 'リセット要求が発生しました',
            body: build_team_and_problem_summary(team: record.team, problem: record.problem),
            # 自動リセット対応
            options: { problem_code: record.problem.code, team_number: record.team.number, created_at: record.created_at }
          },
          {
            to: record.team,
            problem_id: record.problem_id
          }
        ]
      when 'AddIssueComment', 'StartIssue'
        for_staff = " - #{record.issue.team.name}"
        body = "#{record.issue.problem.body.title}#{record.from_staff ? nil : for_staff}\n#{record.text}"

        [
          {
            to: record.from_staff ? record.issue.team : :staff,
            problem_id: record.issue.problem_id,
            title: record.from_staff ? '質問に返答がありました' : '質問が投稿されました',
            body: body
          },
          {
            to: record.from_staff ? :staff : record.issue.team,
            problem_id: record.issue.problem_id
          }
        ]
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
        <<-MSG
          #{record.problem.writer}解答提出
          #{build_team_and_problem_summary(team: record.team, problem: record.problem)}
        MSG
      when 'AddPenalty'
        # メンションしない
        <<-MSG
          リセット依頼が発生しました
          #{build_team_and_problem_summary(team: record.team, problem: record.problem)}
        MSG
      when 'AddIssueComment'
        return if record.from_staff

        issue = record.issue
        problem = issue.problem

        <<~MSG
          #{problem.writer}質問追加
          #{build_team_and_problem_summary(team: issue.team, problem: problem)}
        MSG
      else
        nil
      end
    end

    def build_team_and_problem_summary(team:, problem:)
      <<-MSG
        問題: #{problem.code} - #{problem.body.title}
        チーム: No#{team.number} - #{team.name}
      MSG
    end
  end
end
