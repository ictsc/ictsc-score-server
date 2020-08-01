class AddPercentColumnToScore < ActiveRecord::Migration[5.2]
  def change
    change_table :scores, bulk: true do |t|
      t.integer 'percent', null: true
    end
  end
end
