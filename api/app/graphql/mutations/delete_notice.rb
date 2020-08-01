# frozen_string_literal: true

module Mutations
  class DeleteNotice < BaseMutation
    field :notice, Types::NoticeType, null: true

    argument :notice_id, ID, required: true

    def resolve(notice_id:)
      # 削除時は事前にフィルタする必要がある
      notice = Notice
        .readables(team: self.current_team!)
        .find_by(id: notice_id)

      raise RecordNotExists.new(Notice, id: notice_id) if notice.nil?

      Acl.permit!(mutation: self, args: { notice: notice })

      if notice.destroy
        { notice: notice }
      else
        add_errors(notice)
      end
    end
  end
end
