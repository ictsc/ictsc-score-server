class RemoveUnusedAttributes < ActiveRecord::Migration[4.2]
  def change
    remove_column :comments, :required_reply, :boolean
  end
end
