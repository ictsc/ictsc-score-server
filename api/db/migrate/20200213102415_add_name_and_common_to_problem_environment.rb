class AddNameAndCommonToProblemEnvironment < ActiveRecord::Migration[6.0]
  def change
    change_table :problem_environments, bulk: true do |t|
      t.string :name, null: false
      t.index %i[problem_id team_id name], unique: true
    end

    change_column_null :problem_environments, :team_id, true
  end
end
