# frozen_string_literal: true

class Acl
  class << self
    def permit!(mutation:, args:)
      raise GraphQL::ExecutionError, "Unpermit mutation #{mutation.class} by #{Context.current_team!.name}" unless allow?(mutation: mutation, args: args)
    end

    def allow?(mutation:, args:)
      mutation = mutation.class.name.demodulize
      team = Context.current_team!

      # temporary
      # rubocop:disable Lint/EmptyWhen
      case mutation
      when 'ApplyCategory', 'ApplyProblem', 'ApplyProblemEnvironment', 'ApplyScore', 'ApplyTeam', 'AddNotice', 'AddProblemSupplement', 'DeleteNotice', 'DeleteProblemSupplement', 'ConfirmingAnswer', 'PinNotice'
        # staff only
        team.staff?
      when 'AddAnswer'
        args.fetch(:problem).opened?(team: team) # && 最終提出から20min
        # player and opened and 最終提出から20s
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
