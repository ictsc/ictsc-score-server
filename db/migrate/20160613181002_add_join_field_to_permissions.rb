class AddJoinFieldToPermissions < ActiveRecord::Migration[4.2]
  def change
    add_column :permissions, :join, :string, { null: false, default: "" }
  end
end
