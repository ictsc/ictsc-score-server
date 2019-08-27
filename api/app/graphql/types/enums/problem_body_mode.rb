# frozen_string_literal: true

module Types
  module Enums
    class ProblemBodyMode < Types::BaseEnum
      values_from ProblemBody.modes
    end
  end
end
