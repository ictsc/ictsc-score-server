class AddUniqueIndexToAttachmentToken < ActiveRecord::Migration[6.0]
  def change
    add_index :attachments, :token, unique: true
  end
end
