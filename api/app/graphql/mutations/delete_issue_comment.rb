# frozen_string_literal: true

module Mutations
  class DeleteIssueComment < GraphQL::Schema::RelayClassicMutation
    field :errors, [String], null: false

    argument :issue_coment_id, ID, required: true

    def resolve(issue_coment_id:)
      issue_comment = IssueComment.find_by!(id: issue_coment_id)
      Acl.permit!(mutation: self, args: { issue_comment: issue_comment })

      if issue_comment.destroy
        # errorsが空なら成功とする
        { errors: [] }
      else
        { errors: issue_comment.errors.full_messages }
      end
    end
  end
end
