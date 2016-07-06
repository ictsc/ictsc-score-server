class AddJoinFieldToPermissions < ActiveRecord::Migration
  def change
    add_column :permissions, :join, :string, { null: false, default: "" }
  end
end
