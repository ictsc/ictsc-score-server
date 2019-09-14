# frozen_string_literal: true

module Mutations
  class ApplyCategory < BaseMutation
    field :category, Types::CategoryType, null: true

    argument :code, String, required: true
    argument :title, String, required: true
    argument :description, String, required: true
    argument :order, Integer, required: true

    def resolve(code:, title:, description:, order:)
      Acl.permit!(mutation: self, args: {})

      category = Category.find_or_initialize_by(code: code)

      if category.update(title: title, description: description, order: order)
        { category: category.readable(team: self.current_team!) }
      else
        add_errors(category)
      end
    end
  end
end
