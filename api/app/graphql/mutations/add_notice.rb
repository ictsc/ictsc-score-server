# frozen_string_literal: true

module Mutations
  class AddNotice < BaseMutation
    field :notice, Types::NoticeType, null: true

    argument :title,          String,  required: true
    argument :text,           String,  required: true
    argument :pinned,         Boolean, required: true
    argument :team_id,        ID,      required: false

    def resolve(title:, text:, pinned:, team_id:)
      Acl.permit!(mutation: self, args: {})

      if team_id.present?
        team = Team.find_by(id: team_id)
        raise RecordNotExists.new(Team, id: team_id) if team.nil?
      end

      notice = Notice.new

      if notice.update(title: title, text: text, pinned: pinned, team: team)
        Notification.notify(mutation: self.graphql_name, record: notice)
        { notice: notice.readable(team: self.current_team!) }
      else
        add_errors(notice)
      end
    end
  end
end
