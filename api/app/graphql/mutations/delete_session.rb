# frozen_string_literal: true

module Mutations
  class DeleteSession < BaseMutation
    field :session, Types::SessionType, null: false

    argument :session_id, ID, required: true

    def resolve(session_id:)
      session = Session.find_by(id: session_id)

      raise RecordNotExists.new(Session, id: session_id) if session.nil?

      Acl.permit!(mutation: self, args: { session: session })

      if Session.destroy(session[:id])
        { session: session }
      else
        add_errors(session)
      end
    end
  end
end
