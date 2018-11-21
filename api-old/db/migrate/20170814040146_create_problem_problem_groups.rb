class CreateProblemProblemGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :problem_groups_problems do |t|
      t.references :problem, null: false
      t.references :problem_group, null: false

      t.timestamps null: false
    end

    add_index :problem_groups_problems, [:problem_id, :problem_group_id], unique: true
  end
end
