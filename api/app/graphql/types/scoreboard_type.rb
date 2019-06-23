# frozen_string_literal: true

module Types
  class ScoreboardType < Types::BaseObject
    # TODO: scoreboard_hide_atで隠すよりfreezeする方が良い気がする?
    #       ただ、自身のスコアも変動しないのは直感的ではない
    # TODO: scoreboard_hide_atで隠すと自身の総得点も分からなくなる
    #       順位を消して、得点のみ表示するようにしたほうが良さそう
  end
end
