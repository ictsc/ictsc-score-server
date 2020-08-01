class AddPortAndServiceColumnToProbEnvTable < ActiveRecord::Migration[6.0]
  def change
    remove_index :problem_environments, column: %i[problem_id team_id name]

    change_table :problem_environments, bulk: true do |t|
      t.string :service, null: false
      t.integer :port, null: false
      t.index %i[problem_id team_id name service], unique: true, name: :problem_environments_on_composit_keys
    end
  end
end
