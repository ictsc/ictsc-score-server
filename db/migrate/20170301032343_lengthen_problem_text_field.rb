class LengthenProblemTextField < ActiveRecord::Migration[5.0]
  def change
  	change_column :problems, :text, :string, limit: 1000
  end
end
