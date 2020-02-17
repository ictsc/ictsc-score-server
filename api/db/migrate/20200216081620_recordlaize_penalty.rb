class RecordlaizePenalty < ActiveRecord::Migration[6.0]
  def change
    remove_index :penalties, column: %i[problem_id team_id]

    change_table :penalties, bulk: true do |t|
      t.remove :count # rubocop:disable Rails/ReversibleMigration
      t.index %i[problem_id team_id created_at], unique: true
    end
  end
end
