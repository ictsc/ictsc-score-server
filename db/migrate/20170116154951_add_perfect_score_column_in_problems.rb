class AddPerfectScoreColumnInProblems < ActiveRecord::Migration[5.0]
  def change
	  add_column :problems, :perfect_point, :integer
  end
end
