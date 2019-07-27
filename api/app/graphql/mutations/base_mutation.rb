# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    def add_errors(*records)
      records.each do |record|
        record.errors.each do |attr, message|
          context.add_error(GraphQL::ExecutionError.new("#{record.model_name} #{attr} #{message}"))
        end
      end

      # resolveの戻り値はハッシュかnilな必要がある
      nil
    end
  end
end
