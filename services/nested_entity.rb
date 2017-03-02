require "sinatra/base"
require "pry"

module Sinatra
  module NestedEntityHelpers
    def filter_entities(member:, resource:, entities:, parent_entity: nil)
      if resource.is_a? Array
        resource.each do |r|
          filter_entities(member: member, resource: r, entities: entities, parent_entity: parent_entity)
        end
        return
      end

      r = resource
      entities.each.with_index do |entity, i|
        begin
          k = entity.singularize.capitalize.constantize
        rescue NameError
          parent_klass = parent_entity.singularize.capitalize.constantize
          k = parent_klass.reflections[entity].class_name.constantize
        end

        action = (entity == "comments") ? "#{parent_entity}_#{entity}" : ""

        case r[entity]
        when Array
          r[entity].select!{|rr| k.readables(user: member, action: action).ids.include?(rr["id"]) }
          filter_entities(member: member, resource: r[entity], entities: entities[(i+1)..-1], parent_entity: entity) if 1 < entities.size
          return
        when Hash
          if not k.readables(user: member, action: action).to_a.any?{|x| x.id = r[entity]["id"] }
            r.delete(entity)
            return
          end
          r = r[entity]
          parent_entity = entity
        else
          return
          # raise "Entity not exist: #{entity}"
        end
      end
    end

    def as_json_of(klass, nested_params:, by:, as_option: {}, id: nil)
      # includes: { answers: { comments: {}, score: {} }, creator: {}, issues: { comments: {} } }
      #       as: { include: { answers: { include: { comments: {}, score: {} } }, creator: {}, issues: { include: { comments: {} } } } }
      includes_param, as_param = nested_params.inject([{}, {}]) do |(includes, as), nested_entity|
        i, a = includes, as
        nested_entity.each do |key|
          i[key] ||= {}
          i = i[key]

          a[:include] ||= {}
          a[:include][key] ||= {}
          a = a[:include][key]
        end

        [includes, as]
      end

      # binding.pry
      as_param.deep_merge!(as_option)

      resources = klass.readables(user: by).includes(includes_param)
      resources = resources.where(id: id.to_i) if id
      resources.as_json(as_param).reject{|x| x["id"].nil? }
    end

    #    ary: ["answers","answers-comments","answers-score","issues","issues-comments","creator"]
    # return: [[:answers], [:answers, :comments], [:answers, :score], [:creator], [:issues], [:issues, :comments]]
    def nested_params_from_flat_array(ary)
      return [] if ary.empty?
      ary \
        .sort \
        .tap{|x| x.select!{|y| x.grep(/^#{y}-/).empty? } } \
        .map{|x| x.split(?-).map(&:to_sym) }
    end

    def generate_nested_hash(klass:, by:, params:, id: nil, as_option: {})
      np = params || []
      np = np.split(?,) if np.is_a? String
      np = nested_params_from_flat_array(np) if np.is_a? Array

      # binding.pry
      resources = as_json_of(klass, nested_params: np, by: by, as_option: as_option, id: id&.to_i)
      # binding.pry

      np.map{|x| x.map(&:to_s) }.each do |entities|
        filter_entities(member: by, resource: resources, entities: entities, parent_entity: klass.to_s.downcase.pluralize)
      end

      return resources.first if id
      resources
    end
  end

  helpers NestedEntityHelpers
end
