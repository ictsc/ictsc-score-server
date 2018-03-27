class RenameFlagIconUrl < ActiveRecord::Migration[5.1]
  def change
    rename_column :problem_groups, :flag_icon_url, :icon_url
  end
end
