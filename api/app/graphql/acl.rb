# frozen_string_literal: true

class Acl
  class << self
    def permit!(mutation:, args:)
      raise GraphQL::ExecutionError, "Unpermit mutation #{mutation.class} by #{Context.current_team!.name}" unless allow?(mutation: mutation, args: args)
    end

    def allow?(mutation:, args:)
      mutation = mutation.class.name.demodulize
      team = Context.current_team!

      # audienceはデータの作成・更新・削除は一切できない
      return false if team.audience?

      case mutation
      when 'ApplyCategory', 'ApplyProblem', 'ApplyProblemEnvironment', 'ApplyScore', 'ApplyTeam', 'AddNotice', 'AddProblemSupplement', 'ConfirmingAnswer', 'PinNotice'
        # staff only
        team.staff?
      when 'AddAnswer'
        # player and opened and 最終提出から20s
        problem = args.fetch(:problem)
        return false if !team.player? || !problem.body.readable?(team: team)

        problem.latest_answer_created_at(team: team) <= Time.current - Config.grading_delay_sec.seconds
      when 'AddIssueComment', 'TransitionIssueState'
        # staff of issue owner
        team.staff? || args.fetch(:issue).readable?(team: team)
      when 'StartIssue'
        # player and opened
        team.player? && args.fetch(:problem).body.readable?(team: team)
      when 'DeleteCategory', 'DeleteProblem', 'DeleteProblemEnvironment'
        team.staff?
      when 'DeleteNotice'
        team.staff? && Config.before_delete_time_limit?(args.fetch(:notice).created_at)
      when 'DeleteProblemSupplement'
        team.staff? && Config.before_delete_time_limit?(args.fetch(:problem_supplement).created_at)
      when 'DeleteIssueComment'
        # owner and readable and 送信してから一定時間内以内
        issue_comment = args.fetch(:issue_comment)
        issue_comment.team_id == team.id &&
          issue_comment.readable?(team: team) &&
          Config.before_delete_time_limit?(issue_comment.created_at)
      else
        raise UnhandledClass, mutation
      end
    end
  end
end
