class RenameTeamPrivateColumnToProblems < ActiveRecord::Migration[5.2]
  def change
    rename_column :problems, :team_private, :team_isolate
  end
end
