# frozen_string_literal: true

class CustomContext < GraphQL::Query::Context
  def current_team!
    self.fetch(:current_team)
  end
end
