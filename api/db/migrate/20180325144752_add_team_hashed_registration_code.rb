class AddTeamHashedRegistrationCode < ActiveRecord::Migration[5.1]
  def change
    add_column :teams, :hashed_registration_code, :string, null: false
    add_index :teams, :hashed_registration_code, unique: true
  end
end
