# frozen_string_literal: true

module Mutations
  class DeleteNotice < BaseMutation
    argument :notice_id, ID, required: true

    def resolve(notice_id:)
      notice = Notice.find_by(id: notice_id)
      raise RecordNotExists.new(Notice, id: notice_id) if notice.nil?

      Acl.permit!(mutation: self, args: { notice: notice })

      if notice.destroy
        {}
      else
        add_errors(notice)
      end
    end
  end
end
