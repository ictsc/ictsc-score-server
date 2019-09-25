# frozen_string_literal: true

module Types
  # 全ユーザーが見える情報のみ返す
  # UIの描画に使われる
  class ContestInfoType < Types::BaseObject
    field :competition_time,      [[Types::DateTime]], null: false
    field :grading_delay_sec,     Integer,             null: false
    field :hide_all_score,        Boolean,             null: false
    field :realtime_grading,      Boolean,             null: false
    field :text_size_limit,       Integer,             null: false
    field :delete_time_limit_sec, Integer,             null: false
    field :guide_page,            String,              null: false
  end
end
