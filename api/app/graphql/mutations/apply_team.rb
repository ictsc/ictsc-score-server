# frozen_string_literal: true

module Mutations
  class ApplyTeam < GraphQL::Schema::RelayClassicMutation
    field :team, Types::TeamType, null: true
    field :errors, [String], null: false

    argument :role,         Types::Enums::TeamRole, required: true
    argument :number,       Integer, required: true
    argument :name,         String, required: true
    argument :password,     String, required: false
    argument :organization, String, required: false
    argument :color,        String, required: false

    def resolve(role:, number:, name:, password:, organization: nil, color: nil)
      Acl.permit!(mutation: self, args: {})

      team = Team.find_or_initialize_by(number: number)

      if team.update(role: role, name: name, password: password, organization: organization, color: color)
        { team: team.readable, errors: [] }
      else
        { errors: team.errors.full_messages }
      end
    rescue StandardError => e
      raise GraphQL::ExecutionError, e.message
    end
  end
end
