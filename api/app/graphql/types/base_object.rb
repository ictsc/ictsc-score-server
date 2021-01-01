# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    field_class Types::BaseField

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
        self.fields.map {|key, field|
          type = self.get_type_class(field.type)
          type.kind.composite? ? nil : key
        }
          .compact
      end

      # フィールド一覧をクエリとして使える形式で返す
      def to_fields_query(with: nil)
        base_query = self.non_composite_field_names.join(' ')
        relative_query = self.get_relative_fields_query(*with)
        relative_query.blank? ? base_query : "#{base_query}\n#{relative_query}"
      end

      # have_one, have_many, belongs_to関係にあるフィールどをクエリとして使える形で返す
      def get_relative_fields_query(*names)
        names
          .map {|name| "#{name} { #{self.fields.fetch(name).type.to_fields_query} }" }
          .join("\n")
      end

      def get_operation_arguments_query(name)
        query = self.fields
          .fetch(name)
          .arguments
          .map {|(key, arg)| "$#{key}: #{arg.type.graphql_definition}" }
          .join(', ')

        query.empty? ? '' : "(#{query})"
      end

      def get_arguments_query(name)
        query = self.fields
          .fetch(name)
          .arguments
          .map {|(key, _arg)| "#{key}: $#{key}" }
          .join(', ')

        query.empty? ? '' : "(#{query})"
      end
    end
  end
end
