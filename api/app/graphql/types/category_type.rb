# frozen_string_literal: true

module Types
  class CategoryType < Types::BaseObject
    field :id,          ID,                   null: false
    field :code,        String,               null: true
    field :title,       String,               null: false
    field :description, String,               null: false
    field :order,       Integer,              null: false
    field :problems,    [Types::ProblemType], null: false
    field :created_at,  Types::DateTime,      null: false
    field :updated_at,  Types::DateTime,      null: false

    def problems
      AssociationLoader.for(Category, __method__).load(self.object)
    end
  end
end
