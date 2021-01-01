# frozen_string_literal: true

# e.g.
#   expect(response_json).to have_gq_errors
#   expect(response_json).to_not have_gq_errors
#   expect(response_json).to have_gq_errors('UNAUTHORIZED')
RSpec::Matchers.define :have_gq_errors do |expected|
  match do |json|
    next false if !json.key?('errors') || json['errors'].empty?

    if expected.present?
      # errorsには複数のエラーが入っている可能性がある
      json['errors'].any? {|error| error.dig('extensions', 'code') == expected }
    else
      true
    end
  end
end

# TODO: delete
# post_graphql '{ me { id } }'
# "operationName"=> "Problem"
# "variables"=> {"id"=>"3eb22c84-8376-476c-aeac-2ac7c3249259"}
# "query"=> "query Problem($id: ID!) {\n  problem(id: $id) { }

module GraphqlHelpers
  # レスポンスからフィールドの部分のみ抜き出す
  # 例: query { me { id } } を投げた場合
  #   レスポンスは { data: { me { id: "ID" } } }
  #   戻り地は { id: "ID" }
  #
  # @return [Hash]
  def response_gql
    self.response_json.fetch('data').first.last
  end

  # graphqlのリクエストを送るベースメソッド
  # 結果はexample内からアクセスできるresponseに格納される
  # $DEBUG = trueにすると送信するクエリを出力する
  #
  # @param query [String] クエリ文字列
  # @param variables [Hash] クエリの変数
  # @param operation_name [String] クエリのオペレーション名
  # @return [nil]
  def post_graphql(query, variables: nil, operation_name: nil)
    if $DEBUG
      puts
      pp query
      puts
    end

    # postはresponseに結果を書き込む
    post(graphql_path, params: { query: query, variables: variables, operation_name: operation_name }, as: :json)
    # 常に200を返す用に作っているためここで検証する
    expect(response).to have_http_status(:ok)
    nil
  end

  # POSTリクエストでクエリを投げる
  #
  # @param name [String] クエリ名(camelCase)
  # @param variables [Hash] クエリの引数
  # @param field [String]  クエリの戻り値
  # @param field_with [String, Array<String>] クエリの戻り値に追加したい関連名
  # @return [nil]
  def post_query(name, variables: nil, field_with: nil, field: Types::QueryType.get_fields_query(name, with: field_with))
    operation_name = name.camelcase(:upper)
    operation_arguments = Types::QueryType.get_operation_arguments_query(name)
    arguments = Types::QueryType.get_arguments_query(name)

    query = <<~QUERY
      query #{operation_name}#{operation_arguments} {
        #{name}#{arguments} {
          #{field}
        }
      }
    QUERY

    post_graphql(query, variables: variables, operation_name: operation_name)
  end

  # POSTリクエストでミューテーションを投げる
  # helperとしてincludeされるので呼び出し時のコンテキストを利用できる
  #
  # @param name [String] ミューテーション名(camelCase)
  # @param input [Hash] ミューテーションの引数
  # @param field [String]  ミューテーションの戻り値
  # @param field_with [Hash<String, String, Array<String>>] クエリの戻り値に追加したい関連名(e.g. { 'team' => 'attachments' })
  # @return [nil]
  def post_mutation(name = self.gen_graphql_name_from_top_description, input:, field_with: nil, field: gen_mutation_field_query(name, with: field_with))
    operation_name = name.camelcase(:upper)
    operation_arguments = Types::MutationType.get_operation_arguments_query(name)
    arguments = Types::MutationType.get_arguments_query(name)

    query = <<~QUERY
      mutation #{operation_name}#{operation_arguments} {
        #{name}#{arguments} {
          #{field}
        }
      }
    QUERY

    post_graphql(query, variables: { input: input }, operation_name: operation_name)
  end

  # 最上位のdescribeをGraphQLのクエリ名にして返す
  # @return [String] クエリ名のcamelCase
  def gen_graphql_name_from_top_description
    constant = self.class.top_level_description.constantize
    constant.graphql_name.camelcase(:lower)
  end

  # mutation_nameに対応するMutationのフィールドのクエリ文字列を返す
  # @param mutation_name [String] ミューテーション名(camelCase)
  def gen_mutation_field_query(mutation_name, with: nil)
    mutation = Types::MutationType
      .fields
      .fetch(mutation_name)
      .mutation

    mutation.fields.map {|field_name, field|
      if field.type.kind.composite?
        # TODO: Types::* のモンキーパッチに依存しているのでどうにかしたい
        child_fields = field.type.to_fields_query(with: with&.fetch(field_name, nil))
        "#{field_name} { #{child_fields} }"
      else
        field_name
      end
    }
      .join("\n")
  end
end
