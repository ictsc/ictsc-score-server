class ChangeEnvNoteNullfify < ActiveRecord::Migration[6.0]
  def change
    change_column_null :problem_environments, :note, false, ''
  end
end
