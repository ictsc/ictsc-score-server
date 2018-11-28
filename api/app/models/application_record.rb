ROLE_ID = {
  admin: 2,
  writer: 3,
  participant: 4,
  viewer: 5,
  nologin: 1,
}

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # TODO: 移行が終わったらconcernsにしたりする
  include AccountHelpers
  include AttributeHelpers
  include CompetitionHelpers
  include Crypt
  include JSONHelpers
  include NestedEntityHelpers
  include NotificationHelpers

  extend AccountHelpers
  extend AttributeHelpers
  extend CompetitionHelpers
  extend Crypt
  extend JSONHelpers
  extend NestedEntityHelpers
  extend NotificationHelpers

  def self.required_attribute_names(options = {})
    options[:include] ||= []
    options[:include].map!(&:to_sym)

    options[:exclude] ||= []
    options[:exclude].map!(&:to_sym)

    fields = self.validators
                 .reject{|x| x.options[:if] }
                 .flat_map(&:attributes)
                 .map do |x|
                   reflection = self.reflections[x.to_s]
                   if reflection&.kind_of?(ActiveRecord::Reflection::BelongsToReflection)
                     reflection.foreign_key.to_sym
                   else
                     x
                   end
                 end

    fields - options[:exclude] + options[:include]
  end

  def notification_payload(state: :created, **data)
    {
      type: self.class.to_s.downcase,
      resource_id: id,
      state: state,
      data: data
    }.compact
  end

  # 参照キーも取得できる
  def self.all_column_names(reference_keys: true)
    cols = self.column_names
    cols += self.reflections.keys if reference_keys
    cols
  end
end
