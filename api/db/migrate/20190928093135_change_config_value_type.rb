class ChangeConfigValueType < ActiveRecord::Migration[5.2]
  def change
    change_table :configs, bulk: true do |t|
      # 運用中にマイグレーションすることは無いのでReversibleでなくてよい
      t.remove :value # rubocop:disable Rails/ReversibleMigration
      t.json :value, null: false
    end
  end
end
