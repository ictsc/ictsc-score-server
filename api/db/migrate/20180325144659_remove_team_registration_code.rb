class RemoveTeamRegistrationCode < ActiveRecord::Migration[5.1]
  def change
    remove_column :teams, :registration_code
  end
end
