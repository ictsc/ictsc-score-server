require 'sinatra/base'

module Sinatra
  module ActiveRecordHelpers
    def attribute_names_of(klass:, only_required: false, **options)
      raise 'klass must be kind of Class' unless klass.is_a? Class

      options[:include] ||= []
      options[:include].map!(&:to_sym)

      options[:exclude] ||= []
      options[:exclude].map!(&:to_sym)

      attribute_names = if only_required
                          klass.required_attribute_names
                        else
                          klass.attribute_names.map(&:to_sym)
                        end

      attribute_names - %i(id created_at updated_at) - options[:exclude] + options[:include]
    end

    # ハッシュから指定したクラスのフィールドのみ取り出す
    def params_to_attributes_of(klass:, object: params, **options)
      raise 'klass must be kind of Class' unless klass.is_a? Class

      keys = attribute_names_of(klass: klass, **options)
      keys.inject({}) do |hash, attr_name|
        hash[attr_name] = object[attr_name] if object.key?(attr_name)
        next hash
      end
    end

    def filled_all_attributes_of?(klass:, only_required: false, **options)
      raise 'klass must be kind of Class' unless klass.is_a? Class

      required_attribute_names = attribute_names_of(klass: klass, only_required: only_required, **options)
      filled_attribute_names = params_to_attributes_of(klass: klass, **options).keys

      Set[*filled_attribute_names].superset? Set[*required_attribute_names]
    end

    def insufficient_attribute_names_of(klass:, only_required: false, **options)
      required_attribute_names = attribute_names_of(klass: klass, only_required: only_required, **options)

      required_attribute_names - params_to_attributes_of(klass: klass, **options).keys
    end
  end

  helpers ActiveRecordHelpers
end
