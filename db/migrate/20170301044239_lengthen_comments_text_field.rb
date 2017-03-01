class LengthenCommentsTextField < ActiveRecord::Migration[5.0]
  def change
    change_column :comments, :text, :string, limit: 1000
  end
end
