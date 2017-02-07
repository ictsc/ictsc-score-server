class AddActionFieldToPermissions < ActiveRecord::Migration
  def change
    add_column :permissions, :action, :string, { null: false, default: "" }
  end
end
