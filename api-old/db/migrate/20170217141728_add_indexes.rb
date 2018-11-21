class AddIndexes < ActiveRecord::Migration[5.0]
  def change
    add_index :answers, :id, unique: true
    add_index :answers, :team_id
    add_index :attachments, :id, unique: true
    add_index :issues, :id, unique: true
    add_index :members, :id, unique: true
    add_index :members, :login, unique: true
    add_index :notices, :id, unique: true
    add_index :problem_groups, :id, unique: true
    add_index :problems, :id, unique: true
    add_index :roles, :name, unique: true
    add_index :scores, :id, unique: true
    add_index :scores, :answer_id, unique: true
    add_index :teams, :id, unique: true
  end
end
