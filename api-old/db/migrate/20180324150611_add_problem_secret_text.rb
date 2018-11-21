class AddProblemSecretText < ActiveRecord::Migration[5.1]
  def change
    add_column :problems, :secret_text, :string, null: false, default: '', limit: 4000
  end
end
