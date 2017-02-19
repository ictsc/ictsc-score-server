class RemoveNameFieldFromNotices < ActiveRecord::Migration[5.0]
  def change
    remove_column :notices, :name
  end
end
