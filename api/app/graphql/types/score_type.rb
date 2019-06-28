# frozen_string_literal: true

module Types
  class ScoreType < Types::BaseObject
    field :id,         ID,      null: false
    field :point,      Integer, null: false # 得点の割合0~100%
    field :problem_id, ID,      null: false
    field :solved,     Boolean, null: false

    # TODO: actual_pointみたいな perfect_point * pointをAPI側で計算して返すといいかもしれない
  end
end
