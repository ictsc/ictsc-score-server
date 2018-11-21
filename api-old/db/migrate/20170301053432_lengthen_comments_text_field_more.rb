class LengthenCommentsTextFieldMore < ActiveRecord::Migration[5.0]
  def change
    change_column :comments, :text, :string, limit: 4000
  end
end
