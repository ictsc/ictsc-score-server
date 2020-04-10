# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    # あまりにも多用するのでショートハンド化
    def current_team!
      self.context.current_team!
    end

    class << self
      # 'AnswerType' を Answerクラスにする
      def model_by_query_name
        self.graphql_name.constantize
      end

      # AssociationLoaderを使ったレコード読み込みを手軽に定義する
      #
      # e.g. AnswerType での `has_one :score` は以下を定義する
      #
      # def score
      #   AssociationLoader.for(self.context, Answer, :score).load(self.object)
      # end
      #
      def has_many(field, column = field, &block) # rubocop:disable Naming/PredicateName
        model = self.model_by_query_name

        class_eval do
          if block
            define_method(field) do
              AssociationLoader.for(self.context, model, column).load(self.object).then(&block)
            end
          else
            define_method(field) do
              AssociationLoader.for(self.context, model, column).load(self.object)
            end
          end
        end
      end

      alias has_one has_many

      # RecordLoaderを使ったレコード読み込みを手軽に定義する
      #
      # e.g. AnswerType での `belongs_to :problem` は以下を定義する
      #
      # def problem
      #   RecordLoader.for(Problem).load(self.object.problem_id)
      # end
      #
      def belongs_to(field, &block)
        foreign_column = self.model_by_query_name.reflections[field.to_s]
        foreign_key = foreign_column.foreign_key
        foreign_model = foreign_column.klass

        class_eval do
          if block
            define_method(field) do
              RecordLoader.for(self.context, foreign_model).load(self.object[foreign_key]).then(&block)
            end
          else
            define_method(field) do
              RecordLoader.for(self.context, foreign_model).load(self.object[foreign_key])
            end
          end
        end
      end

      def get_type_class(type)
        if type.non_null? || type.list?
          self.get_type_class(type.of_type)
        else
          type
        end
      end

      # scalarやenumなど値としてそのまま使えるキーを返す
      def non_composite_field_names
        self.fields.map {|name, field|
          type = self.get_type_class(field.type)
          type.kind.composite? ? nil : name
        }
          .compact
      end

      # フィールド一覧をクエリとして使える形式で返す
      def to_fields_query
        self.non_composite_field_names.join(' ')
      end
    end
  end
end
