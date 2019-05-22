# frozen_string_literal: true

module Mutations
  class ApplyCategory < GraphQL::Schema::RelayClassicMutation
    field :category, Types::CategoryType, null: true
    field :errors, [String], null: false

    argument :code, String, required: true
    argument :title, String, required: true
    argument :description, String, required: true
    argument :order, Integer, required: true

    def resolve(code:, title:, description:, order:)
      Acl.permit!(mutation: self, args: {})

      category = Category.find_or_initialize_by(code: code)

      if category.update(title: title, description: description, order: order)
        { category: category.readable, errors: [] }
      else
        { errors: category.errors.full_messages }
      end
    rescue StandardError => e
      raise GraphQL::ExecutionError, e.message
    end
  end
end
