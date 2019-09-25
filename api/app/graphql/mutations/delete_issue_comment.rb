# frozen_string_literal: true

module Mutations
  class DeleteIssueComment < BaseMutation
    field :issue_coment, Types::IssueCommentType, null: true

    argument :issue_coment_id, ID, required: true

    def resolve(issue_coment_id:)
      # 削除時は事前にフィルタする必要がある
      issue_comment = IssueComment
        .readables(team: self.current_team!)
        .find_by(id: issue_coment_id)

      raise RecordNotExists.new(IssueComment, id: issue_coment_id) if issue_comment.nil?

      Acl.permit!(mutation: self, args: { issue_comment: issue_comment })

      if issue_comment.destroy
        # 削除されたレコードはreadableが使えないのでカラムのみフィルタする
        { issue_comment: issue_comment }
      else
        add_errors(issue_comment)
      end
    end
  end
end
