class AddTeamsToRegistrationCodeField < ActiveRecord::Migration
  def change
  	add_column :teams, :registration_code, :string, { null: false, default: "" }
  end
end
