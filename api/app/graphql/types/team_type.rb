# frozen_string_literal: true

module Types
  class TeamType < Types::BaseObject
    field :id,           ID, null: false
    field :role,         Types::Enums::TeamRole, null: false
    field :name,         String,  null: true
    field :organization, String,  null: true
    field :number,       Integer, null: true
    field :color,        String,  null: true
  end
end
