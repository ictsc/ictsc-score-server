class FixTypeOfReferencePointOfProblems < ActiveRecord::Migration[5.0]
  def change
    change_column :problems, :reference_point, :integer
  end
end
