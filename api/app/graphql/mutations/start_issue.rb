# frozen_string_literal: true

module Mutations
  class StartIssue < BaseMutation
    field :issue,         Types::IssueType,        null: true
    field :issue_comment, Types::IssueCommentType, null: true

    # 質問を開始する問題IDと最初のコメントを引数にとる
    argument :problem_id, ID,     required: true
    argument :text,       String, required: true

    def resolve(problem_id:, text:)
      problem = Problem.find_by(id: problem_id)
      raise RecordNotExists.new(Problem, id: problem_id) if problem.nil?

      Acl.permit!(mutation: self, args: { problem: problem })

      issue = Issue.new(status: 'unsolved', problem: problem, team: self.current_team!)
      issue_comment = IssueComment.new(text: text, from_staff: self.current_team!.staff?)

      # issueも同時にsaveされる
      if issue_comment.update(issue: issue)
        Notification.notify(mutation: self.mutation_name, record: issue)
        { issue: issue.readable(team: self.current_team!), issue_comment: issue_comment.readable(team: self.current_team!) }
      else
        add_errors(issue, issue_comment)
      end
    end
  end
end
