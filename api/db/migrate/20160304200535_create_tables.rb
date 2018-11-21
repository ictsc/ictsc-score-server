class CreateTables < ActiveRecord::Migration[4.2]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.string :organization

      t.timestamps null: false
    end

    create_table :members do |t|
      t.boolean :admin, null: false
      t.string :name, null: false
      t.string :login, null: false
      t.string :hashed_password, null: false

      t.references :team

      t.timestamps null: false
    end

    create_table :problems do |t|
      t.string :title, null: false
      t.string :text, null: false
      t.datetime :opened_at, null: false
      t.datetime :closed_at, null: false

      t.references :creator, null: false

      t.timestamps null: false
    end

    create_table :issues do |t|
      t.string :title, null: false
      t.boolean :closed, null: false

      t.references :problem, null: false

      t.timestamps null: false
    end

    create_table :answers do |t|
      t.string :text, null: false

      t.references :problem, null: false
      t.references :score
      t.references :team

      t.timestamps null: false
    end

    create_table :scores do |t|
      t.integer :point, null: false

      t.references :answer, null: false
      t.references :marker, null: false

      t.timestamps null: false
    end

    create_table :comments do |t|
      t.string :text, null: false
      t.boolean :required_reply, null: false

      t.references :member, null: false
      t.references :problem
      t.references :issue

      t.timestamps null: false
    end
  end
end
