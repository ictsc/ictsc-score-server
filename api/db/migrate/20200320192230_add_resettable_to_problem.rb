class AddResettableToProblem < ActiveRecord::Migration[6.0]
  def change
    add_column :problem_bodies, :resettable, :boolean, null: false, default: true # rubocop:disable Rails/BulkChangeTable
    change_column_default :problem_bodies, :resettable, from: '', to: nil
  end
end
