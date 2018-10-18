class AddTeamIdToIssue < ActiveRecord::Migration[4.2]
  def change
    add_reference :issues, :team
    change_column_null :issues, :team_id, false
  end
end
