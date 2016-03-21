require "sinatra/base"

module Sinatra
  module ActiveRecordHelpers
    def attribute_names_of_class(klass, options = {})
      options[:include] ||= []
      options[:include].map!(&:to_s)

      options[:exclude] ||= []
      options[:exclude].map!(&:to_s)

      raise "klass must be kind of Class" unless klass.kind_of? Class

      ret = klass.attribute_names - %w(id created_at updated_at) - options[:exclude] + options[:include]
      ret.map(&:to_sym)
    end

    def attribute_values_of_class(klass, options = {})
      raise "klass must be kind of Class" unless klass.kind_of? Class

      options[:include] ||= []
      options[:include].map!(&:to_sym)

      keys = attribute_names_of_class(klass, options) + options[:include]
      ret = keys.inject(Hash.new) do |hash, attr_name|
        hash[attr_name.to_sym] = params[attr_name] if params.key?(attr_name.to_s)
        next hash
      end

      ret
    end

    def satisfied_required_fields?(klass, options = {})
      raise "klass must be kind of Class" unless klass.kind_of? Class

      attribute_keys = attribute_values_of_class(klass, options).keys
      Set[*attribute_keys].superset?(Set[*klass.required_fields(options)])
    end

    def insufficient_fields(klass, options = {})
      klass.required_fields(options) - attribute_values_of_class(klass, options).keys
    end
  end

  helpers ActiveRecordHelpers
end
