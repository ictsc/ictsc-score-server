class DropPermissionTable < ActiveRecord::Migration[5.0]
  def change
  	drop_table :permissions
  end
end
