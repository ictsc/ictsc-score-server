class RemoveColumnsInProblemsForIctsc7 < ActiveRecord::Migration[5.0]
  def change
    remove_column :problems, :opened_at
    remove_column :problems, :closed_at
  end
end
