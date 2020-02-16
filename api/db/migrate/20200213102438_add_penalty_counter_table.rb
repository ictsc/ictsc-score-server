class AddPenaltyCounterTable < ActiveRecord::Migration[6.0]
  def change
    create_table :penalties, id: :uuid do |t|
      t.integer    'count', null: false
      t.references :problem, null: false, type: :uuid
      t.references :team,    null: false, type: :uuid
      t.timestamps           null: false
      t.index %i[problem_id team_id], unique: true
    end
  end
end
