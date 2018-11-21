class AddAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :attachments do |t|
      t.string :filename, null: false
      t.references :member

      t.timestamps null: false
    end
  end
end
