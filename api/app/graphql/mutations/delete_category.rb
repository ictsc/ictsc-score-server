# frozen_string_literal: true

module Mutations
  class DeleteCategory < BaseMutation
    field :category, Types::CategoryType, null: true

    argument :code, String, required: true

    def resolve(code:)
      # 削除時は事前にフィルタする必要がある
      category = Category
        .readables(team: self.current_team!)
        .find_by(code: code)

      raise RecordNotExists.new(Category, code: code) if category.nil?

      Acl.permit!(mutation: self, args: { category: category })

      if category.destroy
        { category: category }
      else
        add_errors(category)
      end
    end
  end
end
