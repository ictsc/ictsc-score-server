# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    # あまりにも多用するのでショートハンド化
    def current_team!
      self.context.current_team!
    end

    def add_errors(*records)
      records.each do |record|
        record.errors.each do |attr, message|
          self.context.add_error(GraphQL::ExecutionError.new("#{record.model_name} #{attr} #{message}"))
        end
      end

      # resolveの戻り値はハッシュかnilな必要がある
      nil
    end
  end
end
