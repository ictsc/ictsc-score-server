# frozen_string_literal: true

module Types
  module Enums
    class TeamRole < Types::BaseEnum
      values_from Team.roles
    end
  end
end
