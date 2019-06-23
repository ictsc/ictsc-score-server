# frozen_string_literal: true

module Mutations
  class DeleteNotice < GraphQL::Schema::RelayClassicMutation
    field :errors, [String], null: false

    argument :notice_id, ID, required: true

    def resolve(notice_id:)
      notice = Notice.find!(notice_id)
      Acl.permit!(mutation: self, args: { notice: notice })

      if notice.destroy
        # errorsが空なら成功とする
        { errors: [] }
      else
        { errors: notice.errors.full_messages }
      end
    end
  end
end
