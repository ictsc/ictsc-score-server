class AddFieldsForIctsc8 < ActiveRecord::Migration[5.1]
  def change
    add_column :problem_groups, :visible, :boolean, null: false, default: true
    add_column :problem_groups, :completing_bonus_point, :integer, null: false
    add_column :problem_groups, :flag_icon_url, :string
  end
end
