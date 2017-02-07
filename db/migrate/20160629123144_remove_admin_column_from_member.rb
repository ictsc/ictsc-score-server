class RemoveAdminColumnFromMember < ActiveRecord::Migration
  def change
    remove_column :members, :admin, :boolean, null: false, default: false
  end
end
