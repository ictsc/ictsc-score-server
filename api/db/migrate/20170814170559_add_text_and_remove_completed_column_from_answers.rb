class AddTextAndRemoveCompletedColumnFromAnswers < ActiveRecord::Migration[5.1]
  def change
    remove_column :answers, :completed
    remove_column :answers, :completed_at
    add_column :answers, :text, :string, null: false, limit: 4000
  end
end
