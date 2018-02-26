require "sinatra/base"
require "pry"

module Sinatra
  module NestedEntityHelpers
    # 文字列からモデルを求める
    def solve_model(entity:, parent_entity:)
      begin
        entity.singularize.capitalize.constantize
      rescue NameError
        parent_entity.singularize.capitalize.constantize
          .reflections[entity].class_name.constantize
      end
    end

    # NOTE: 解読中
    # readablesを呼んでくれてるっぽい
    # @param member []
    # @param resource []
    # @param entities []
    # @param parent_entity []
    # @return []
    def filter_entities(member:, resource:, entities:, parent_entity: nil)
      if resource.is_a? Array
        resource.each do |r|
          filter_entities(member: member, resource: r, entities: entities, parent_entity: parent_entity)
        end
        return
      end

      r = resource
      entities.each.with_index do |entity, i|
        model = solve_model(entity: entity, parent_entity: parent_entity)
        # NOTE: 謎
        action = (entity == "comments") ? "#{parent_entity}_#{entity}" : ""

        case r[entity]
        when Array
          r_entity_readable_ids = model.readables(user: member, action: action).ids
          r[entity].select!{|rr| r_entity_readable_ids.include?(rr["id"]) }
          filter_entities(member: member, resource: r[entity], entities: entities[(i+1)..-1], parent_entity: entity) if 1 < entities.size
          return
        when Hash
          if not model.readables(user: member, action: action).to_a.any?{|x| x.id = r[entity]["id"] }
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

    # NOTE: 解読中
    # データを再帰的に取得する readablesを使ってる
    # @param klass []
    # @param nested_params []
    # @param by []
    # @param as_option []
    # @param id [] 取得するデータのid
    # @param action []
    # @return
    def as_json_of(klass, nested_params:, by:, as_option: {}, id: nil, action: "", where: {})
      includes_param, as_param = nested_params.inject([{}, {}]) do |(includes, as), nested_entity|
        # includes: { answers: { comments: {}, score: {} }, creator: {}, issues: { comments: {} } }
        #       as: { include: { answers: { include: { comments: {}, score: {} } }, creator: {}, issues: { include: { comments: {} } } } }

        # 再帰的にデフォルト値をセットする
        i, a = includes, as
        nested_entity.each do |key|
          # デフォルト値をセット
          i[key] ||= {}
          a[:include] ||= {}
          a[:include][key] ||= {}

          # 次の階層に移る
          i = i[key]
          a = a[:include][key]
        end

        [includes, as]
      end

      as_param.deep_merge!(as_option)

      # ここでは最上位のモデルからしかreadablesがよばれない
      resources = klass.readables(user: by, action: action).includes(includes_param).where(where)

      resources = resources.where(id: id.to_i) if id
      resources.as_json(as_param).reject{|x| x["id"].nil? }
    end

    # ネストするパラメータを正規化
    # @params ary [Array<String>] ["answers","answers-comments","answers-score","issues","issues-comments","creator"]
    # @return [Array<Array<Symbol>>] [[:answers, :comments], [:answers, :score], [:creator], [:issues, :comments]]
    def nested_params_from_flat_array(ary)
      return [] if ary.empty?

      # ソート
      # ['answers', 'answers-score'] -> ['answers-score']
      # シンボル化 'answers-score' -> [:answers, :score]
      ary
        .sort
        .tap{|array| array.select!{|str| array.grep(/^#{str}-/).empty? } }
        .map{|str| str.split('-').map(&:to_sym) }
    end

    # 指定モデルのデータに別のモデルデータを結合(ネスト)する
    #
    # @param klass [] ベースデータ(モデル)
    # @param by [] 呼び出しユーザー(権限)
    # @param params [] ネストするモデル
    # @param id [] 取得するデータのid
    # @param as_option []
    # @param apply_filter [Boolean] trueだとフィルタが適応される
    # @param action []
    # @param where []
    # @return []
    # @return [] idを指定すると返すデータは1つだけ
    def generate_nested_hash(klass:, by:, params:, id: nil, as_option: {}, apply_filter: true, action: "", where: {})
      nested_params = case params
        when String
          params.split(',')
        when nil
          []
        else
          params
        end

      # パラメータを正規化
      nested_params = nested_params_from_flat_array(nested_params) if nested_params.is_a? Array

      # 再帰的にデータを取得
      resources = as_json_of(klass, nested_params: nested_params, by: by, as_option: as_option, id: id&.to_i, action: action, where: where)

      if apply_filter
        nested_params.map{|x| x.map(&:to_s) }.each do |entities|
          filter_entities(member: by, resource: resources, entities: entities, parent_entity: klass.to_s.downcase.pluralize)
        end
      end

      return resources.first if id

      resources
    end
  end

  helpers NestedEntityHelpers
end
