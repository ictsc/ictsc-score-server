# frozen_string_literal: true

module Mutations
  class AddNotice < GraphQL::Schema::RelayClassicMutation
    field :notice, Types::NoticeType, null: true
    field :errors, [String], null: false

    argument :title, String, required: true
    argument :text, String, required: true
    argument :pinned, Boolean, required: true
    argument :target_team_id, ID, required: false

    def resolve(title:, text:, pinned:, target_team_id:)
      Acl.permit!(mutation: self, args: {})

      notice = Notice.new

      if notice.update(title: title, text: text, pinned: pinned, target_team: Team.find_by!(id: target_team_id))
        { notice: notice.readable, errors: [] }
      else
        { errors: notice.errors.full_messages }
      end
    end
  end
end
