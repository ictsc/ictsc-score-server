# frozen_string_literal: true

module Mutations
  class PinNotice < BaseMutation
    field :notice, Types::NoticeType, null: true

    argument :notice_id, ID,      required: true
    argument :pinned,    Boolean, required: true

    def resolve(notice_id:, pinned:)
      Acl.permit!(mutation: self, args: {})

      notice = Notice.find_by(id: notice_id)
      raise RecordNotExists.new(Notice, id: notice_id) if notice.nil?

      if notice.update(pinned: pinned)
        { notice: notice.readable(team: self.current_team!) }
      else
        add_errors(notice)
      end
    end
  end
end
