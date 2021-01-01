# frozen_string_literal: true

class ApiSchema < GraphQL::Schema
  mutation Types::MutationType
  query Types::QueryType
  context_class CustomContext
  use GraphQL::Batch

  # max_depth 10
  # max_complexity 300
  # default_max_page_size 20
end
