# frozen_string_literal: true

module RequestHelpers
  def json_response
    JSON.parse(response.body)
  end

  def post_query(query_string)
    post graphql_path, params: { query: query_string }, as: :json
  end
end
