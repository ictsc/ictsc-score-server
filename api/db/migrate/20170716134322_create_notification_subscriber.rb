class CreateNotificationSubscriber < ActiveRecord::Migration[5.1]
  def change
    create_table :notification_subscribers do |t|
      t.string :channel_id, null: false
      t.references :subscribable, polymorphic: true, index: false # NOTE: auto index name becomes too long (64 chars < ), so create manually

      t.timestamps null: false
    end

    add_index :notification_subscribers, [:subscribable_type, :subscribable_id], unique: true, name: 'index_notification_subscribers_on_subscribable'
  end
end
