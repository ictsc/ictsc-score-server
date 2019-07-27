# frozen_string_literal: true

module Mutations
  class AddNotice < BaseMutation
    field :notice, Types::NoticeType, null: true

    argument :title, String, required: true
    argument :text, String, required: true
    argument :pinned, Boolean, required: true
    argument :target_team_id, ID, required: false

    def resolve(title:, text:, pinned:, target_team_id:)
      Acl.permit!(mutation: self, args: {})
      team = Team.find_by(id: target_team_id)
      raise RecordNotExists.new(Team, id: target_team_id) if team.nil?

      notice = Notice.new

      if notice.update(title: title, text: text, pinned: pinned, target_team: team)
        { notice: notice.readable }
      else
        add_errors(notice)
      end
    end
  end
end
