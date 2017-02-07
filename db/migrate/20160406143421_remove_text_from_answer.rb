class RemoveTextFromAnswer < ActiveRecord::Migration
  def change
    change_table :answers do |t|
      t.remove :text
    end
  end
end
