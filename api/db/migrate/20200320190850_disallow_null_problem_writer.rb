class DisallowNullProblemWriter < ActiveRecord::Migration[6.0]
  def change
    change_column_null :problems, :writer, false, ''
  end
end
