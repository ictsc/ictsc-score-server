require "sinatra/base"

module Sinatra
  module ActiveRecordHelpers
    def attribute_names_of_class(klass, options = {})
      options[:include] ||= []
      options[:include].map!(&:to_s)

      options[:exclude] ||= []
      options[:exclude].map!(&:to_s)

      return nil unless klass.kind_of? Class

      ret = klass.attribute_names - %w(id created_at updated_at) - options[:exclude] + options[:include]
      ret.map(&:to_sym)
    end

    def attribute_values_of_class(klass, options = {})
      return nil unless klass.kind_of? Class

      ret = attribute_names_of_class(klass, options).inject(Hash.new) do |hash, attr_name|
        hash[attr_name] = params[attr_name]
        next hash
      end

      options[:include] ||= []
      options[:include].map!(&:to_sym).each do |attr_name|
        ret[attr_name] = params[attr_name]
      end

      ret
    end

    def satisfy_required_fields?(klass, options = {})
      return nil unless klass.kind_of? Class

      attribute_nonnil_values = attribute_values_of_class(klass, options).reject{|k, v| v.nil? }
      required_keys = klass.required_fields(options)

      Set[*attribute_nonnil_values.keys].superset?(Set[*required_keys])
    end
  end

  helpers ActiveRecordHelpers
end
