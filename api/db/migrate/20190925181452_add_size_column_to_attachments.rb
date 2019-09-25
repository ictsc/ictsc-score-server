class AddSizeColumnToAttachments < ActiveRecord::Migration[5.2]
  def change
    # 運用されているDBに対してマイグレーションをかけることはないのでデフォルト値は指定しない
    add_column :attachments, :size, :integer, null: false # rubocop:disable Rails/NotNullColumn
  end
end
