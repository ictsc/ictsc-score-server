class AddProblemGroupModel < ActiveRecord::Migration[5.0]
  def change
    create_table :problem_groups do |t|
      t.string :name, null: false
      t.string :description

      t.timestamps null: false
    end

    add_reference :problems, :problem_group
  end
end
