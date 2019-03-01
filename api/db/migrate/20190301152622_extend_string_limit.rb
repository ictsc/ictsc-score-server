class ExtendStringLimit < ActiveRecord::Migration[5.2]
  def change
    change_column :problems, :text, :string, limit: 10240
    change_column :answers, :text, :string, limit: 10240
    change_column :comments, :text, :string, limit: 10240
    change_column :notices, :text, :string, limit: 10240
  end
end

