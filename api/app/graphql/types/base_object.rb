# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    class << self
      def model_by_query_name
        self.class_name.sub(/Type$/, '').constantize
      end

      # AssociationLoaderを使ったレコード読み込みを手軽に定義する
      # 例えばAnswerType での `has_one :score` は以下を定義する
      #
      # def score
      #   AssociationLoader.for(self.context, Answer, :score).load(self.object)
      # end
      #
      def has_many(field, column = field, &block) # rubocop:disable Naming/PredicateName
        model = model_by_query_name

        class_eval do
          if block
            define_method(field) do
              AssociationLoader.for(self.context, model, column).load(self.object, &block).then(&block)
            end
          else
            define_method(field) do
              AssociationLoader.for(self.context, model, column).load(self.object, &block)
            end
          end
        end
      end

      alias has_one has_many
    end
  end
end
