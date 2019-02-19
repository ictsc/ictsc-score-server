class AddAnswerPtcUniq < ActiveRecord::Migration[5.2]
  def change
    add_index :answers, [:problem_id, :team_id, :created_at], unique: true
  end
end
