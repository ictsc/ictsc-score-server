class AddSecretTextToTeam < ActiveRecord::Migration[6.0]
  def change
    add_column :teams, :secret_text, :string, null: false, limit: 8192 # rubocop:disable Rails/NotNullColumn
  end
end
