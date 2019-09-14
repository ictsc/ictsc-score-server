# frozen_string_literal: true

module Types
  class AttachmentType < Types::BaseObject
    field :id,           ID,              null: false
    field :token,        String,          null: false
    field :filename,     String,          null: false
    field :content_type, String,          null: false
    field :team,         Types::TeamType, null: true
    field :team_id,      ID,              null: true
    field :created_at,   Types::DateTime, null: false
    # dataはGraphQLでは返さない

    belongs_to :team
  end
end
