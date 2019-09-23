# frozen_string_literal: true

# belongs_to
class RecordLoader < GraphQL::Batch::Loader
  def initialize(context, model, column: model.primary_key, where: nil)
    @context = context
    @model = model
    @column = column.to_s
    @column_type = model.type_for_attribute(@column)
    @where = where
  end

  def load(key)
    super(@column_type.cast(key))
  end

  def perform(keys)
    query(keys).each {|record| fulfill(record.public_send(@column), record) }
    keys.each {|key| fulfill(key, nil) unless fulfilled?(key) }
  end

  private

  def query(keys)
    scope = @model
    scope = scope.where(@where) unless @where.nil?
    scope.readables(team: @context.current_team!).where(@column => keys)
  end
end
