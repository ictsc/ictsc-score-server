# frozen_string_literal: true

module Mutations
  class PinNotice < GraphQL::Schema::RelayClassicMutation
    field :notice, Types::NoticeType, null: true
    field :errors, [String], null: false

    argument :notice_id, ID, required: true
    argument :pinned, Boolean, required: true

    def resolve(notice_id:, pinned:)
      Acl.permit!(mutation: self, args: {})

      notice = Notice.find!(notice_id)

      if notice.update(pinned: pinned)
        { notice: notice.readable, errors: [] }
      else
        { errors: notice.errors.full_messages }
      end
    end
  end
end
