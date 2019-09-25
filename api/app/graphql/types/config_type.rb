# frozen_string_literal: true

module Types
  # 設定変更時のみstaffから参照される
  # 通常時はContestInfoTypeを参照する
  class ConfigType < Types::BaseObject
    field :key,        ID,     null: false
    field :value,      String, null: false
    field :value_type, String, null: false
  end
end
