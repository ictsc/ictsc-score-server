class AddUniqueToFca < ActiveRecord::Migration[5.1]
  def change
    add_index :first_correct_answers, [:team_id, :problem_id], unique: true
  end
end
