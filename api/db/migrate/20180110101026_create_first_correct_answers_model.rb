class CreateFirstCorrectAnswersModel < ActiveRecord::Migration[5.1]
  def change
    create_table :first_correct_answers do |t|
      t.belongs_to :problem, null: false, index: { unique: true }
      t.references :team,    null: false

      t.timestamps           null: false
    end
  end
end
