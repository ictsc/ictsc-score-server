class AddTeamRegistrationCodeAgain < ActiveRecord::Migration[5.2]
  def change
  	add_column :teams, :registration_code, :string, null: false
  end
end
