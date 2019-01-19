class NotificationSubscriber < ApplicationRecord
  validates :channel_id, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_-]+\z/ }

  belongs_to :subscribable, polymorphic: true

  after_initialize def set_default_channel_id
    self.channel_id ||= SecureRandom.uuid
  end
end
