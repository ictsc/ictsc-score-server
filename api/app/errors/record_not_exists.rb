# frozen_string_literal: true

class RecordNotExists < GraphQL::ExecutionError
  def initialize(model, **params)
    super("#{model} #{params} not exists")
  end
end
