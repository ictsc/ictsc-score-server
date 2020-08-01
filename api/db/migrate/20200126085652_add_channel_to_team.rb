class AddChannelToTeam < ActiveRecord::Migration[6.0]
  def change
    add_column :teams, :channel, :string, null: false # rubocop:disable Rails/NotNullColumn
  end
end
