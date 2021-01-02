# frozen_string_literal: true

# e.g.
#   expect(response_json).to have_gql_errors
#   expect(response_json).to_not have_gql_errors
#   expect(response_json).to have_gql_errors('unauthorized')
RSpec::Matchers.define :have_gql_errors do |expected|
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
  # 戻り値はnest_fieldsを指定すれば2層目まで指定可能
  #
  # @param name [String] クエリ名(camelCase)
  # @param variables [Hash] クエリの引数
  # @param field [String] クエリの戻り値を自由に設定したい場合のみ指定する
  # @param nest_fields [Array<String>] クエリの戻り値に追加する関連名(composite field names)
  # @return [nil]
  def post_query(name: nil, variables: nil, field: nil, nest_fields: [])
    name ||= self.class.top_level_description
    field ||= GraphqlQueryBuilder.build_query_field_query(name: name, nest_fields: nest_fields)
    operation_name = name.camelcase(:upper)
    query = GraphqlQueryBuilder.build_query(name: name, field: field, operation_name: operation_name)

    post_graphql(query, variables: variables, operation_name: operation_name)
  end

  # POSTリクエストでミューテーションを投げる
  # 戻り値はnest_fieldsを指定すれば2層目まで指定可能
  #
  # @param name [String] ミューテーション名(camelCase)
  # @param input [Hash] ミューテーションの引数
  # @param field [String] ミューテーションの戻り値を自由に設定したい場合のみ指定する
  # @param nest_fields [Hash{String => Array<String>}] クエリの戻り値に追加したい関連名の組み合わせ(e.g. { 'team' => ['attachments'] })
  # @return [nil]
  def post_mutation(input:, name: nil, field: nil, nest_fields: {})
    name ||= self.class.top_level_description
    field ||= GraphqlQueryBuilder.build_mutation_field_query(name: name, nest_fields: nest_fields)
    operation_name = name.camelcase(:upper)
    query = GraphqlQueryBuilder.build_mutation(name: name, field: field, operation_name: operation_name)

    post_graphql(query, variables: { input: input }, operation_name: operation_name)
  end
end
