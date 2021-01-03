# frozen_string_literal: true

# GraphQLのクエリ文字列を実装から生成する補助をするメソッド郡
# 主にテストに使われるがrspecには一切依存しない
#
# TODO: 制限なくネストしたフィールドを取得できるような作りにしたほうがむしろシンプルな実装になる
#       現状ではbuild_composite_fields_queryとfields_to_queryが似たような別のことをするメソッドになってしまっている
module GraphqlQueryBuilder
  module_function

  # 引数からGraphQLのクエリ文字列を構築する
  def build_query(name:, field:, operation_name:)
    operation_arguments = self.build_operation_arguments_query(name: name, type: Types::QueryType)
    arguments = self.build_arguments_query(name: name, type: Types::QueryType)

    <<~QUERY
      query #{operation_name}#{operation_arguments} {
        #{name}#{arguments} {
          #{field}
        }
      }
    QUERY
  end

  # 引数からGraphQLのミューテーション文字列を構築する
  def build_mutation(name:, field:, operation_name:)
    operation_arguments = self.build_operation_arguments_query(name: name, type: Types::MutationType)
    arguments = self.build_arguments_query(name: name, type: Types::MutationType)

    <<~QUERY
      mutation #{operation_name}#{operation_arguments} {
        #{name}#{arguments} {
          #{field}
        }
      }
    QUERY
  end

  # nameに対応するroot queryのフィールドのtypeを返す
  #
  # @param name [String] root queryのフィールド名
  # @return [GraphQL::BaseType]
  def find_root_query_type_by_name(name)
    Types::QueryType.fields.fetch(name).type.unwrap
  end

  # 登録されているミューテーション一覧からnameにマッチするミューテーションを取り出す
  #
  # @param name [String] ミューテーション名(camelCase)
  # @return [Mutations::BaseMutation]
  def find_mutation_class_by_name(name)
    Types::MutationType
      .fields
      .fetch(name)
      .mutation
  end

  # オペレーションの引数になるクエリ文字列を返す
  #
  # @param name [String] typeに含まれるフィールド名
  # @param type [Types::BaseObject] Types::QueryTypeやTypes::MutationType
  # @return [String]
  def build_operation_arguments_query(name:, type:)
    query = type.fields
      .fetch(name)
      .arguments
      .map {|(key, arg)| "$#{key}: #{arg.type.graphql_definition}" }
      .join(', ')

    query.empty? ? '' : "(#{query})"
  end

  # クエリの引数になるクエリ文字列を返す
  #
  # @param name [String] typeに含まれるフィールド名
  # @param type [Types::BaseObject] Types::QueryTypeやTypes::MutationType
  # @return [String]
  def build_arguments_query(name:, type:)
    query = type.fields
      .fetch(name)
      .arguments
      .map {|(key, _arg)| "#{key}: $#{key}" }
      .join(', ')

    query.empty? ? '' : "(#{query})"
  end

  # fieldsから構造体のような複数のフィールドを持つ要素を弾く
  #
  # @param fields [Hash<String => GraphQL::Schema::Field>]
  # @return [Hash<String => GraphQL::Schema::Field>]
  def reject_composite_fields(fields)
    fields.reject {|_key, field| field.type.unwrap.kind.composite? }
  end

  # nameに対応するQueryのフィールドのクエリ文字列を返す
  #
  # @param name [String] クエリ名(camelCase)
  # @param nest_fields [Array<String>] クエリの戻り値に追加する関連名(composite field names)
  # @return [String] フィールド一覧を文字列にしたもの
  def build_query_field_query(name:, nest_fields:)
    type = self.find_root_query_type_by_name(name)
    self.fields_to_query(fields: type.fields, nest_fields: nest_fields)
  end

  # nameに対応するMutationのフィールドのクエリ文字列を返す
  #
  # @param name [String] ミューテーション名(camelCase)
  # @param nest_fields [Hash{String => Array<String>}] クエリの戻り値に追加したい関連名の組み合わせ(e.g. { 'team' => ['attachments'] })
  # @return [String] フィールド一覧を文字列にしたもの
  def build_mutation_field_query(name:, nest_fields:)
    mutation_class = self.find_mutation_class_by_name(name)

    mutation_class.fields.map {|field_name, field|
      if field.type.kind.composite?
        child_fields = self.fields_to_query(
          fields: field.type.fields,
          nest_fields: nest_fields.fetch(field_name, [])
        )
        "#{field_name} { #{child_fields} }"
      else
        field_name
      end
    }
      .join("\n")
  end

  # 関連(composite field)のクエリ文字列を構築する
  #
  # @param nest_field_names [Array<String>] fieldsのうちクエリ構築の対象になるフィールド名
  # @param fields [Hash<String => GraphQL::Schema::Field>]
  # @return [String]
  def build_composite_fields_query(fields:, nest_field_names:)
    nest_field_names
      .map {|name|
        child_fields = fields_to_query(fields: fields.fetch(name).type.unwrap.fields)
        "#{name} { #{child_fields} }"
      }
      .join("\n")
  end

  # fieldsをクエリ文字列に変換する
  # composite fieldsはnest_fieldsで指定されたもののみ展開される
  #
  # @param fields [Hash<String => GraphQL::Schema::Field>]
  # @param nest_fields [Array<String>] クエリに追加する関連名(composite field names)
  # @return [String]
  def fields_to_query(fields:, nest_fields: [])
    base_query = self.reject_composite_fields(fields).keys.join(' ')
    relative_query = self.build_composite_fields_query(fields: fields, nest_field_names: nest_fields)
    relative_query.blank? ? base_query : "#{base_query}\n#{relative_query}"
  end
end
