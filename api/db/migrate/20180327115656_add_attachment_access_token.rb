class AddAttachmentAccessToken < ActiveRecord::Migration[5.1]
  def change
    add_column :attachments, :access_token, :string, null: false
  end
end
