class AddColumnsInProblemsForIctsc7 < ActiveRecord::Migration[5.0]
  def change
    add_reference :problems, :problem_must_solve_before
    add_column :problems, :reference_point, :string
  end
end
