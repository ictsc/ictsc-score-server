class AddRankToProblem < ActiveRecord::Migration[5.1]
  def change
    add_column :problems, :rank, :integer, default: 0, null: false
  end
end
