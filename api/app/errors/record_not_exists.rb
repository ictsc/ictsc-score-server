# frozen_string_literal: true

class RecordNotExists < GraphQL::ExecutionError
  def initialize(model, **params)
    super("#{model.inspect} #{params.inspect} not exists")
  end
end
