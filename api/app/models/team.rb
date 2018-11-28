class Team < ApplicationRecord
  validates :name, presence: true
  validates :hashed_registration_code, presence: true
  validates_associated :notification_subscriber

  has_many :members, dependent: :nullify
  has_many :answers, dependent: :destroy
  has_many :issues, dependent: :destroy
  has_one :notification_subscriber, dependent: :destroy, as: :subscribable
  has_many :first_correct_answers, dependent: :nullify

  before_validation def build_notification_subscriber_if_not_exists
    build_notification_subscriber if not notification_subscriber
  end

  # For FactoryBot to pass plain registration_code to spec from factory
  attr_accessor :registration_code

  # method: POST
  def self.allowed_to_create_by?(user = nil, action: "")
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer]
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
    when ROLE_ID[:admin], ROLE_ID[:writer]
      true
    else # nologin, ...
      false
    end
  end

  def self.allowed_nested_params(user:)
    %w(members answers answers-score issues issues-comments issues-comments-member)
  end

  def self.readable_columns(user:, action: '', reference_keys: true)
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer]
      self.all_column_names(reference_keys: reference_keys)
    else
      self.all_column_names(reference_keys: reference_keys) - %w(hashed_registration_code)
    end
  end

  scope :filter_columns, ->(user:, action: '') {
    cols = readable_columns(user: user, action: action, reference_keys: false)
    next none if cols.empty?
    select(*cols)
  }

  scope :readable_records, ->(user:, action: '') {
    all
  }

  # method: GET
  scope :readables, ->(user:, action: '') {
    readable_records(user: user, action: action)
      .filter_columns(user: user, action: action)
  }

  def self.find_by_registration_code(registration_code)
    find {|team| Crypt.compare_password(registration_code, team.hashed_registration_code)}
  end
end
