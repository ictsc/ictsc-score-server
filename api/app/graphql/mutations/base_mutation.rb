# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    # あまりにも多用するのでショートハンド化
    def current_team!
      self.context.current_team!
    end

    def mutation_name
      # class_nameを使ってはいけない
      self.class.name.demodulize
    end

    def add_error_message(message, ast_node: nil, options: nil, extensions: nil)
      Rails.logger.error message
      self.context.add_error(GraphQL::ExecutionError.new(message, message, ast_node, options, extensions))
    end

    def add_errors(*records)
      records.each do |record|
        record.errors.each do |attr, message|
          message = "#{record.model_name} #{attr} #{message}"
          self.add_error_message(GraphQL::ExecutionError.new(message))
        end
      end

      # resolveの戻り値はハッシュかnilな必要がある
      nil
    end
  end
end
