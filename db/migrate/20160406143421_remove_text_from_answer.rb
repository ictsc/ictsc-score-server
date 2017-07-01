class RemoveTextFromAnswer < ActiveRecord::Migration[4.2]
  def change
    change_table :answers do |t|
      t.remove :text
    end
  end
end
