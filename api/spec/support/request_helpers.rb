# frozen_string_literal: true

module RequestHelpers
  def response_json
    JSON.parse(response.body)
  end

  def post_query(query_string, variables: nil, operation_name: nil)
    post graphql_path, params: { query: query_string, variables: variables, operation_name: operation_name }, as: :json
  end

  def post_mutation(query_string, variables: nil, operation_name: nil)
    post_query "mutation { #{query_string} }", variables: variables, operation_name: operation_name
  end
end
