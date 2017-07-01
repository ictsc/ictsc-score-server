class SetDefaultValueToRequiredReplyInComments < ActiveRecord::Migration[4.2]
  def change
    change_column :comments, :required_reply, :boolean, null: false, default: false
  end
end
