# frozen_string_literal: true

module Mutations
  class DeleteAttachment < BaseMutation
    field :attachment, Types::AttachmentType, null: true

    argument :id, String, required: true

    def resolve(id:)
      # 削除時は事前にフィルタする必要がある
      attachment = Attachment
        .readables(team: self.current_team!)
        .find_by(id: id)

      raise RecordNotExists.new(Attachment, id: id) if attachment.nil?

      Acl.permit!(mutation: self, args: { attachment: attachment })

      if attachment.destroy
        { attachment: attachment }
      else
        add_errors(attachment)
      end
    end
  end
end
