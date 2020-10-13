# frozen_string_literal: true

# 非公開API(Preloader)を使っているためバージョンアップ時は注意
raise 'unsupported AR version' unless ActiveRecord.version.to_s == '6.0.3.4'

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
    @association_reflection = @model.reflections[@association_name.to_s]
    @is_collection = @association_reflection.collection?
    validate
    super()
  end

  def load(record)
    raise TypeError, "#{@model} loader can't load association for #{record.class}" unless record.is_a?(@model)

    # ApplyScoreなどでPreloaderを使わずにアソシエーションを呼ぶ場合もあるが、
    # preload_associationを通さないレコード取得は情報漏洩する可能性がある
    # return Promise.resolve(read_association(record)) if association_loaded?(record)

    super(record)
  end

  # We want to load the associations on all records, even if they have the same id
  def cache_key(record)
    record.id
  end

  def perform(records)
    Rails.logger.debug "AssociationLoader#perform #{@model}##{@association_name}".magenta

    @preload = preload_association(records)
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
    @association_reflection.class_name.constantize
  end

  def read_association(record)
    return nil if @preload.blank?

    # Preloaderはpreload_scopeを指定するとloadedとしてマークしないため自前で処理する
    if @is_collection
      @preload.first.records_by_owner[record].presence || []
    else
      @preload.first.records_by_owner[record]&.first
    end
  end

  def association_loaded?(record)
    record.association(@association_name).loaded?
  end
end
