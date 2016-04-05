class SetDefaultValueToRequiredReplyInComments < ActiveRecord::Migration
  def change
    change_column :comments, :required_reply, :boolean, null: false, default: false
  end
end
