# frozen_string_literal: true

module Mutations
  class ApplyTeam < BaseMutation
    field :team, Types::TeamType, null: true

    argument :role,         Types::Enums::TeamRole, required: true
    argument :beginner,     Boolean,                required: true
    argument :number,       Integer,                required: true
    argument :organization, String,                 required: true
    argument :color,        String,                 required: true
    argument :secret_text,  String,                 required: true
    argument :name,         String,                 required: true
    argument :password,     String,                 required: false

    # 通知無効
    argument :silent,       Boolean,                required: false

    # passwordを省略した場合は更新されない
    def resolve(role:, beginner:, number:, secret_text:, name:, password:, organization:, color:, silent: false)
      Acl.permit!(mutation: self, args: {})

      team = Team.find_or_initialize_by(number: number)

      if team.update(role: role, beginner: beginner, secret_text: secret_text, name: name, password: password, organization: organization, color: color)
        Notification.notify(mutation: self.graphql_name, record: team) unless silent
        { team: team.readable(team: self.current_team!) }
      else
        add_errors(team)
      end
    end
  end
end
