# frozen_string_literal: true

class Acl
  class << self
    # 各Mutationをcurrent_teamがその引数で実行できるか判定する
    def permit!(mutation:, args:)
      unless allow?(mutation: mutation, args: args)
        current_team_name = mutation.context.current_team!.name
        raise GraphQL::ExecutionError, "Unpermitted mutation #{mutation.class} by #{current_team_name}"
      end
    end

    private

    # permit!の本体
    def allow?(mutation:, args:)
      Rails.logger.debug mutation

      team = mutation.context.current_team!

      # audienceはデータの作成・更新・削除は一切できない
      return false if team.audience?

      case mutation.graphql_name
      when 'ApplyCategory', 'ApplyProblem', 'ApplyProblemEnvironment', 'ApplyScore', 'ApplyTeam', 'AddNotice', 'AddProblemSupplement', 'ConfirmingAnswer', 'PinNotice', 'UpdateConfig', 'RegradeAnswers',
        'DeleteAttachment', 'DeleteCategory', 'DeleteNotice', 'DeleteProblem', 'DeleteProblemEnvironment', 'DeleteProblemSupplement', 'DeleteSession', 'DeleteTeam'
        team.staff?
      when 'AddAnswer', 'AddPenalty'
        # player and opened and 解答とペナルティ最終提出から一定時間以内
        problem = args.fetch(:problem)
        return false if !team.player? || !problem.body.readable?(team: team)

        problem.latest_answer_created_at(team: team) <= Time.current - Config.grading_delay_sec.seconds &&
          problem.latest_penalty_created_at(team: team) <= Time.current - Config.reset_delay_sec.seconds
      when 'AddIssueComment', 'TransitionIssueState'
        # staff of issue owner
        team.staff? || args.fetch(:issue).readable?(team: team)
      when 'StartIssue'
        # player and opened
        team.player? && args.fetch(:problem).body.readable?(team: team)
      when 'DeleteIssueComment'
        # owner and readable and 送信してから一定時間以内
        issue_comment = args.fetch(:issue_comment)
        issue_comment.team_id == team.id &&
          issue_comment.readable?(team: team)
      else
        raise UnhandledClass, mutation.graphql_name
      end
    end
  end
end
