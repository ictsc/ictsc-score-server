class Role < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :rank, presence: true
  validates_associated :notification_subscriber

  has_many :members
  has_one :notification_subscriber, dependent: :destroy, as: :subscribable

  before_create def build_notification_subscriber_if_not_exists
    build_notification_subscriber if not notification_subscriber
    notification_subscriber.valid?
  end

  # method: POST
  def self.allowed_to_create_by?(user = nil, action: "")
    case user&.role_id
    when ROLE_ID[:admin]
      true
    else # nologin, ...
      false
    end
  end

  def readable?(by: nil, action: '')
    self.class.readables(user: by, action: action).exists?(id: id)
  end

  # method: GET, PUT, PATCH, DELETE
  def allowed?(method:, by: nil, action: "")
    return readable?(by: by, action: action) if method == 'GET'

    case by&.role_id
    when ROLE_ID[:admin]
      true
    else # nologin, ...
      false
    end
  end

  def self.readable_columns(user:, action: '', reference_keys: true)
    self.all_column_names(reference_keys: reference_keys)
  end

  scope :filter_columns, ->(user:, action: '') {
    cols = readable_columns(user: user, action: action, reference_keys: false)
    next none if cols.empty?
    select(*cols)
  }

  scope :readable_records, ->(user:, action: '') {
    case user&.role_id
    when ROLE_ID[:admin]
      all
    when ROLE_ID[:writer]
      where("rank >= ?", user.role.rank)
    when nil # nologin
      where("id = ?", ROLE_ID[:participant])
    else # nologin, ...
      none
    end
  }

  # method: GET
  scope :readables, ->(user:, action: '') {
    readable_records(user: user, action: action)
      .filter_columns(user: user, action: action)
  }

  # userにそのid(Role#id)のメンバーが作成できるか
  def self.permitted_to_create_by?(user:, role_id:)
    readables(user: user).ids.include?(role_id)
  end
end
