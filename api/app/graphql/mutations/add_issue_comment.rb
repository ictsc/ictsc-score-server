# frozen_string_literal: true

module Mutations
  class AddIssueComment < BaseMutation
    field :issue,         Types::IssueType,        null: true
    field :issue_comment, Types::IssueCommentType, null: true

    argument :issue_id, ID,     required: true
    argument :text,     String, required: true

    def resolve(issue_id:, text:)
      issue = Issue.find_by(id: issue_id)
      raise RecordNotExists.new(Issue, id: issue_id) if issue.nil?

      Acl.permit!(mutation: self, args: { issue: issue })

      issue.transition_by_comment(team: self.current_team!)
      issue_comment = IssueComment.new(text: text, from_staff: self.current_team!.staff?)

      # issueも同時にsaveされる
      if issue_comment.update(issue: issue)
        SlackNotifierJob.perform_later(mutation: self.class.name.demodulize, obj: issue_comment)
        { issue: issue.readable(team: self.current_team!), issue_comment: issue_comment.readable(team: self.current_team!) }
      else
        add_errors(issue, issue_comment)
      end
    end
  end
end
