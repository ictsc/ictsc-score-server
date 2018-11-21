class AddPolymorphicRelationToComments < ActiveRecord::Migration[4.2]
  def change
    change_table :comments do |t|
      t.references :commentable, polymorphic: true, index: true

      t.remove :problem_id
      t.remove :issue_id
    end
  end
end
