class AddCompletedFieldToAnswers < ActiveRecord::Migration[5.0]
  def change
	  add_column :answers, :completed, :boolean, { null: false, default: false }
  end
end
