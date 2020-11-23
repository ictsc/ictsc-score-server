# frozen_string_literal: true

class Acl
  class << self
    def permit!(mutation:, args:)
      raise GraphQL::ExecutionError, "Unpermitted mutation #{mutation.class} by #{mutation.context.current_team!.name}" unless allow?(mutation: mutation, args: args)
    end

    def allow?(mutation:, args:)
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
