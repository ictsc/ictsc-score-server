class RenameNoticeTargetTeamToTeam < ActiveRecord::Migration[6.0]
  def change
    rename_column :notices, :target_team_id, :team_id
  end
end
