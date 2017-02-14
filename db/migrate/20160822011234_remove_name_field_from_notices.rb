class RemoveNameFieldFromNotices < ActiveRecord::Migration
  def change
    remove_column :notices, :name
  end
end
