class AddAnswersTeamWithNotNull < ActiveRecord::Migration
  def change
  	change_column_null :answers, :team_id, false
  end
end
