class AddNotNullConstraintsToBooleanAttributes < ActiveRecord::Migration[4.2]
  def change
    change_column :issues, :closed, :boolean, null: false, default: false
    change_column :members, :admin, :boolean, null: false, default: false
  end
end
