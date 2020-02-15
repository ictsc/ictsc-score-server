class ChangeNullableOfTeamTable < ActiveRecord::Migration[6.0]
  def change
    change_column_null :teams, :organization, false
    change_column_null :teams, :color, false
  end
end
