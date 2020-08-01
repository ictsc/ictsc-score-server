class AddBeginnerColumnToTeam < ActiveRecord::Migration[6.0]
  def change
    add_column :teams, :beginner, :boolean, null: false # rubocop:disable Rails/NotNullColumn
  end
end
