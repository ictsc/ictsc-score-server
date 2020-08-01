# frozen_string_literal: true

class ConflictAnswerConfirming < GraphQL::ExecutionError
  def initialize(confirming)
    super("confirming is already #{confirming}")
  end
end
