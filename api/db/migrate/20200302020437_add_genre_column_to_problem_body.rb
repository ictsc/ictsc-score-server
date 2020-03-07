class AddGenreColumnToProblemBody < ActiveRecord::Migration[6.0]
  def change
    add_column :problem_bodies, :genre, :string, null: false, default: '' # rubocop:disable Rails/BulkChangeTable
    change_column_default :problem_bodies, :genre, from: '', to: nil
  end
end
