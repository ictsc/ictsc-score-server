class ChangeAttachmentTable < ActiveRecord::Migration[5.2]
  def change
    change_table :attachments, bulk: true do |t|
      # 運用中にマイグレーションすることは無いのでReversibleでなくてよい
      t.remove :description # rubocop:disable Rails/ReversibleMigration
      t.string :content_type, null: false
    end
  end
end
