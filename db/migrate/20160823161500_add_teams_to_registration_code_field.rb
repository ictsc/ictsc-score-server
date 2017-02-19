class AddTeamsToRegistrationCodeField < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :registration_code, :string, { null: false, default: "" }
  end
end
