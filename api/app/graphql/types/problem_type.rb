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
    field :answers,             [Types::AnswerType],             null: false
    field :penalties,           [Types::PenaltyType],            null: false
    field :issues,              [Types::IssueType],              null: false

    # 全問題取得が100ms程遅くなるので注意
    field :solved_count,        Integer,                         null: false

    # created_atとupdated_atは意味がないので見せない(bodyを見るべき)

    def open_at_begin
      self.object.open_at&.begin
    end

    def open_at_end
      self.object.open_at&.end
    end

    has_one  :body
    has_many :environments
    has_many :supplements
    has_many :answers
    has_many :issues
    has_many :penalties
    belongs_to :previous_problem
    belongs_to :category
  end
end
