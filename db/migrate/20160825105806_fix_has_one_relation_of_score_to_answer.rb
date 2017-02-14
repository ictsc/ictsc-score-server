class FixHasOneRelationOfScoreToAnswer < ActiveRecord::Migration
  def change
    remove_column :answers, :score_id
  end
end
