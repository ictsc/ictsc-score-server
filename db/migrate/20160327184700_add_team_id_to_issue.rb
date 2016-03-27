class AddTeamIdToIssue < ActiveRecord::Migration
  def change
  	add_reference :issues, :team
  	change_column_null :issues, :team_id, false
  end
end
