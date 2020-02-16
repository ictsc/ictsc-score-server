# frozen_string_literal: true

module Types
  class TeamType < Types::BaseObject
    field :id,           ID, null: false
    field :role,         Types::Enums::TeamRole, null: false
    field :beginner,     Boolean, null: false
    field :name,         String,  null: false
    field :organization, String,  null: false
    field :number,       Integer, null: false
    field :color,        String,  null: false
    field :secret_text,  String,  null: true
    # channelはgraphqlでは渡さない
    # field :channel,      String,  null: true

    field :attachments,  [Types::AttachmentType], null: false
    field :penalties,    [Types::PenaltyType],    null: false

    has_many :attachments
    has_many :penalties
  end
end
