class AddCriterionColumnToProblemBody < ActiveRecord::Migration[5.2]
  def change
    # 運用されているDBに対してマイグレーションをかけることはないのでデフォルト値は指定しない
    add_column :problem_bodies, :solved_criterion, :integer, null: false # rubocop:disable Rails/NotNullColumn
  end
end
