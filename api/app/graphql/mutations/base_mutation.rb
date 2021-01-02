# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    # Add your custom classes if you have them:
    # This is used for generating payload types
    object_class Types::BaseObject
    # This is used for return fields on the mutation's payload
    field_class Types::BaseField
    # This is used for generating the `input: { ... }` object type
    input_object_class Types::BaseInputObject

    # Mutationのインスタンスから名前にアクセスするショートハンド
    def graphql_name
      self.class.graphql_name
    end

    private

    # 多用するのでショートハンド化
    def current_team!
      self.context.current_team!
    end

    # エラーメッセージをgrpahql-rubyが処理できる形式で登録する
    def add_error_message(message, ast_node: nil, options: nil, extensions: nil)
      Rails.logger.error message
      self.context.add_error(GraphQL::ExecutionError.new(message, ast_node: ast_node, options: options, extensions: extensions))
    end

    # ActiveRecordを受け取って、Errorsを親切なメッセージに変換してadd_error_messageに渡す
    def add_errors(*records)
      records.each do |record|
        record.errors.each do |error|
          message = "#{record.model_name} #{error.attribute} #{error.message}"
          self.add_error_message(message)
        end
      end

      # resolveの戻り値はハッシュかnilな必要がある
      nil
    end
  end
end
