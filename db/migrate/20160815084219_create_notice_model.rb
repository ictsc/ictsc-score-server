class CreateNoticeModel < ActiveRecord::Migration[5.0]
  def change
    create_table :notices do |t|
      t.string :name,    null: false
      t.string :title,   null: false
      t.string :text,    null: false
      t.boolean :pinned, null: false, default: false

      t.references :member, null: false
      t.timestamps          null: false
    end
  end
end
