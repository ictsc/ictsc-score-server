# frozen_string_literal: true

class ApiSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)
  use GraphQL::Batch

  # Add built-in connections for pagination
  # use GraphQL::Pagination::Connections

  context_class CustomContext
  # max_depth 10
  # max_complexity 300
  # default_max_page_size 20
end
