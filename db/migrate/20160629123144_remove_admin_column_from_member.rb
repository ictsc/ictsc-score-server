class RemoveAdminColumnFromMember < ActiveRecord::Migration[5.0]
  def change
    remove_column :members, :admin, :boolean, null: false, default: false
  end
end
