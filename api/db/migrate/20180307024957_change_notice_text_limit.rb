class ChangeNoticeTextLimit < ActiveRecord::Migration[5.1]
  def change
    change_column :notices, :text, :string, null: false, limit: 4000
  end
end
