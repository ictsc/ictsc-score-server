class AddRoles < ActiveRecord::Migration[4.2]
  def change
    create_table :roles do |t|
      t.string :name,  null: false
      t.integer :rank, null: false

      t.timestamps null: false
    end

    create_table :permissions do |t|
      t.string :resource, null: false
      t.string :method,   null: false
      t.string :query,    null: false
      t.string :parameters

      t.references :role

      t.timestamps null: false
    end

    add_reference :members, :role, index: false
  end
end
