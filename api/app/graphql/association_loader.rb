# frozen_string_literal: true

# has_many has_one
class AssociationLoader < GraphQL::Batch::Loader
  def self.validate(model, association_name)
    new(model, association_name)
    nil
  end

  def initialize(context, model, association_name)
    @context = context
    @model = model
    @association_name = association_name
    validate
  end

  def load(record)
    raise TypeError, "#{@model} loader can't load association for #{record.class}" unless record.is_a?(@model)
    return Promise.resolve(read_association(record)) if association_loaded?(record)

    super
  end

  # We want to load the associations on all records, even if they have the same id
  def cache_key(record)
    record.object_id
  end

  def perform(records)
    preload_association(records)
    records.each {|record| fulfill(record, read_association(record)) }
  end

  private

  def validate
    unless @model.reflect_on_association(@association_name)
      raise ArgumentError, "No association #{@association_name} on #{@model}"
    end
  end

  def preload_association(records)
    ::ActiveRecord::Associations::Preloader.new.preload(records, @association_name, association_model.readables(team: @context.current_team!))
  end

  def association_model
    @model.reflections[@association_name.to_s].class_name.constantize
  end

  def read_association(record)
    record.public_send(@association_name)
  end

  def association_loaded?(record)
    record.association(@association_name).loaded?
  end
end
