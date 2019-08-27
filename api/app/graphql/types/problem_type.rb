# frozen_string_literal: true

module Types
  class ProblemType < Types::BaseObject
    # 常時playerが見れるフィールド
    field :id,                  ID,                              null: false
    field :order,               Integer,                         null: false
    field :team_isolate,        Boolean,                         null: false
    field :previous_problem_id, ID,                              null: true
    field :previous_problem,    Types::ProblemType,              null: true
    field :category_id,         ID,                              null: true
    field :category,            Types::CategoryType,             null: true
    # Rangeの[begin, end)
    field :open_at_begin,       Types::DateTime,                 null: true
    field :open_at_end,         Types::DateTime,                 null: true
    # staffのみ見せる
    field :code,                String,                          null: true
    field :writer,              String,                          null: true
    field :secret_text,         String,                          null: true
    # 開放時のみ見れるフィールド
    field :body,                Types::ProblemBodyType,          null: true
    # staffは全チームの環境を見える, playerは自チームのみ
    field :environments,        [Types::ProblemEnvironmentType], null: false
    field :supplements,         [Types::ProblemSupplementType],  null: false
    field :answers,             [Types::AnswerType],             null: true
    field :issues,              [Types::IssueType],              null: false
    field :solved_count,        Integer,                         null: false
    # created_atとupdated_atは意味がないので見せない(bodyを見るべき)

    # field :actual_point # そのチームの、現在の得点を計算して返す
    #                     APIv1では全てのanswers.scoresを取得してUIが算出していたがロードが重い

    def open_at_begin
      self.object.open_at&.begin
    end

    def open_at_end
      self.object.open_at&.end
    end

    def body
      AssociationLoader.for(Problem, __method__).load(self.object)
    end

    def environments
      AssociationLoader.for(Problem, __method__).load(self.object)
    end

    def supplements
      AssociationLoader.for(Problem, __method__).load(self.object)
    end

    def answers
      AssociationLoader.for(Problem, __method__).load(self.object)
    end

    def issues
      AssociationLoader.for(Problem, __method__).load(self.object)
    end

    def previous_problem
      RecordLoader.for(Problem).load(self.object[__method__.to_s.foreign_key])
    end

    def category
      RecordLoader.for(Category).load(self.object[__method__.to_s.foreign_key])
    end

    def solved_count
      AssociationLoader.for(Problem, :first_correct_answers).load(self.object).then(&:size)
    end
  end
end
