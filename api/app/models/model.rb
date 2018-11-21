require_relative 'answer'
require_relative 'attachment'
require_relative 'comment'
require_relative 'first_correct_answer'
require_relative 'issue'
require_relative 'member'
require_relative 'notification_subscriber'
require_relative 'notice'
require_relative 'problem'
require_relative 'problem_group'
require_relative 'role'
require_relative 'score'
require_relative 'setting'
require_relative 'team'
require_relative '../lib/sinatra/competition_helpers'

ROLE_ID = {
  admin: 2,
  writer: 3,
  participant: 4,
  viewer: 5,
  nologin: 1,
}

class ActiveRecord::Base
  include Sinatra::CompetitionHelpers
  extend Sinatra::CompetitionHelpers

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
