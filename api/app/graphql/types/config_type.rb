# frozen_string_literal: true

module Types
  # 設定変更時のみstaffから参照される
  # 通常時はContestInfoTypeを参照する
  class ConfigType < Types::BaseObject
    field :key,        ID,     null: false
    field :value,      String, null: false
    field :value_type, String, null: false

    def value
      if self.object.date?
        # "\"2112-09-03T03:22:00+09:00\""
        self.object.value.iso8601.to_json
      else
        self.object.value.to_json
      end
    end
  end
end
