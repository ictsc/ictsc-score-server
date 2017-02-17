class AddActionFieldToPermissions < ActiveRecord::Migration[5.0]
  def change
    add_column :permissions, :action, :string, { null: false, default: "" }
  end
end
