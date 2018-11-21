class FixHasOneRelationOfScoreToAnswer < ActiveRecord::Migration[5.0]
  def change
    remove_column :answers, :score_id
  end
end
