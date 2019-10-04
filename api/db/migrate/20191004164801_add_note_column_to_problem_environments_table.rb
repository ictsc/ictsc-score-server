class AddNoteColumnToProblemEnvironmentsTable < ActiveRecord::Migration[5.2]
  def change
    add_column :problem_environments, :note, :string, null: true, limit: 8192
  end
end
