class AddCompletedAtFieldToAnswers < ActiveRecord::Migration[5.0]
  def change
    add_column :answers, :completed_at, :datetime, { null: true }
  end
end
