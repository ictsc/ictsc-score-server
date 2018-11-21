class ChangeProblemTextLimit < ActiveRecord::Migration[5.1]
  def change
    change_column :problems, :text, :string, limit: 3000
  end
end
