class ChangeProblemsTextLimit < ActiveRecord::Migration[5.1]
  def change
    change_column :problems, :text, :string, null: false, limit: 4000
  end
end
