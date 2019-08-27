class ChangeIssueSpec < ActiveRecord::Migration[5.2]
  def change
    remove_column :issues, :title, :string
    add_index :issues, %i[team_id problem_id], unique: true
  end
end
