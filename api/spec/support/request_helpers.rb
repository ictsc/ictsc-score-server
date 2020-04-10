# frozen_string_literal: true

module RequestHelpers
  def response_json
    JSON.parse(response.body)
  end

  def post_query(query_string, variables: nil, operation_name: nil)
    if $DEBUG
      puts
      pp query_string
      puts
    end

    post graphql_path, params: { query: query_string, variables: variables, operation_name: operation_name }, as: :json
  end

  # POSTリクエストでミューテーションを投げる
  # helperとしてincludeされるので呼び出し時のコンテキストを利用できる
  #
  # @param mutation [Mutations::BaseMutation] ミューテーションクラス, 最上位のdescribeをデフォルト引数とする
  # @param input [Hash] ミューテーションの引数
  # @param field [String]  ミューテーションの戻り値
  # @return [Response] レスポンス
  def post_mutation(mutation: self.class.top_level_description.constantize, input:, field: mutation.to_fields_query)
    operation_name = mutation.graphql_name
    input_type = mutation.input_type.graphql_name
    mutation_name = mutation.graphql_name.camelcase(:lower)

    query = <<~QUERY
      mutation #{operation_name}($input: #{input_type}!) {
        #{mutation_name}(input: $input) {
          #{field}
        }
      }
    QUERY

    post_query(query, variables: { input: input }, operation_name: operation_name)
  end
end
