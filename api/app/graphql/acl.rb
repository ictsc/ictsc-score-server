# frozen_string_literal: true

class Acl
  class << self
    def permit!(mutation:, args:)
      raise GraphQL::ExecutionError, "Unpermit mutation #{mutation.class} by #{Context.current_team!.name}" unless allow?(mutation: mutation, args: args)
    end

    def allow?(mutation:, args:) # rubocop:disable Metrics/CyclomaticComplexity
      mutation = mutation.class.name.demodulize
      team = Context.current_team!

      # temporary
      # rubocop:disable Lint/EmptyWhen
      case mutation
      when 'ApplyCategory', 'ApplyProblem', 'ApplyProblemEnvironment', 'ApplyScore', 'ApplyTeam', 'AddNotice', 'AddProblemSupplement', 'DeleteNotice', 'DeleteProblemSupplement', 'ConfirmingAnswer', 'PinNotice'
        # staff only
        team.staff?
      when 'AddAnswer'
        # player and opened and 最終提出から20s
        problem = args.fetch(:problem)
        return false if !team.player? || !problem.body.readable?(team: team)

        problem.latest_answer_created_at(team: team) <= Time.current - Config.grading_delay_sec.seconds
      when 'AddIssue'
        # player and opened
      when 'AddIssueComment'
        # opened and issue owner or staff
        # Issue.find_by().readable?
        # team.staff?
      else
        raise UnhandledClass, self
      end
      # rubocop:enable Lint/EmptyWhen
    end
  end
end
