# frozen_string_literal: true

module Types
  class ProblemType < Types::BaseObject
    # 常時playerが見れるフィールド
    field :id,               ID,                              null: false
    field :order,            Integer,                         null: false
    field :team_private,     Boolean,                         null: false
    field :previous_problem, Types::ProblemType,              null: true
    field :category,         Types::CategoryType,             null: true
    # Rangeの[begin, end)
    field :open_at_begin,    Types::DateTime,                 null: true
    field :open_at_end,      Types::DateTime,                 null: true
    # staffのみ見せる
    field :code,             String,                          null: true
    field :writer,           String,                          null: true
    field :secret_text,      String,                          null: true
    # 開放時のみ見れるフィールド
    field :body,             Types::ProblemBodyType,          null: true
    # staffは全チームの環境を見える, playerは自チームのみ
    field :environments,     [Types::ProblemEnvironmentType], null: true
    # created_atとupdated_atは意味がないので見せない(bodyを見るべき)

    # field :actual_point # そのチームの、現在の得点を計算して返す
    #                     APIv1では全てのanswers.scoresを取得してUIが算出していたがロードが重い
    # field :solved_count

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

    def previous_problem
      RecordLoader.for(Problem).load(self.object.previous_problem_id)
    end

    def category
      RecordLoader.for(Category).load(self.object.category_id)
    end

    # field :solved_teams_counts, Integer, null: false
    #   method:, hash_keyか普通にメソッドを定義すれば良さそう
  end
end
