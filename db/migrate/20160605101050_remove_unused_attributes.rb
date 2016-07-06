class RemoveUnusedAttributes < ActiveRecord::Migration
  def change
  	remove_column :comments, :required_reply, :boolean
  end
end
