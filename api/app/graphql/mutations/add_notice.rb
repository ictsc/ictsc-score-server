# frozen_string_literal: true

module Mutations
  class AddNotice < BaseMutation
    field :notice, Types::NoticeType, null: true

    argument :title, String, required: true
    argument :text, String, required: true
    argument :pinned, Boolean, required: true
    argument :target_team_id, ID, required: false

    def resolve(title:, text:, pinned:, target_team_id: nil)
      Acl.permit!(mutation: self, args: {})

      if target_team_id.present?
        team = Team.find_by(id: target_team_id)
        raise RecordNotExists.new(Team, id: target_team_id) if team.nil?
      end

      notice = Notice.new

      if notice.update(title: title, text: text, pinned: pinned, target_team: team)
        { notice: notice.readable }
      else
        add_errors(notice)
      end
    end
  end
end
