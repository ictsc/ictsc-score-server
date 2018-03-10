class AddOrderToProblemGroup < ActiveRecord::Migration[5.1]
  def change
    add_column :problem_groups, :order, :integer, default: 0, null: false
  end
end
