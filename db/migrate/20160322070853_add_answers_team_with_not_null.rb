class AddAnswersTeamWithNotNull < ActiveRecord::Migration[4.2]
  def change
    change_column_null :answers, :team_id, false
  end
end
