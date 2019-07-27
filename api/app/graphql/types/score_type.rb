# frozen_string_literal: true

module Types
  class ScoreType < Types::BaseObject
    field :id,         ID,      null: false
    field :point,      Integer, null: true # 得点の割合0~100% or null
    field :answer_id,  ID,      null: false
    field :solved,     Boolean, null: false

    # TODO: actual_pointみたいな perfect_point * pointをAPI側で計算して返すといいかもしれない
  end
end
