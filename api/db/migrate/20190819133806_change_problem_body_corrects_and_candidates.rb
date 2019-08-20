class ChangeProblemBodyCorrectsAndCandidates < ActiveRecord::Migration[5.2]
  def change
    change_table :problem_bodies, bulk: true do |t|
      # 運用中にマイグレーションすることは無いのでReversibleでなくてよい
      # rubocop:disable Rails/ReversibleMigration
      t.change :candidates, :json, null: false
      t.change :corrects, :json, null: false
      # rubocop:enable Rails/ReversibleMigration
    end
  end
end
