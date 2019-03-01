require 'digest/sha1'

class Team < ApplicationRecord
  validates :name, presence: true
  validates :organization, presence: false
  validates :registration_code, presence: true, uniqueness: true
  validates :hashed_registration_code, presence: true
  validates_associated :notification_subscriber

  has_many :members, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :issues, dependent: :destroy
  has_many :first_correct_answers, dependent: :destroy
  has_one :notification_subscriber, dependent: :destroy, as: :subscribable

  before_validation :build_notification_subscriber_if_not_exists

  def registration_code=(value)
    super(value)
    self.hashed_registration_code = Digest::SHA1.hexdigest(value)
  end

  def build_notification_subscriber_if_not_exists
    build_notification_subscriber unless notification_subscriber
  end

  # method: POST
  def self.allowed_to_create_by?(user = nil, action: '')
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
  def allowed?(method:, by: nil, action: '')
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
      all_column_names(reference_keys: reference_keys)
    else
      all_column_names(reference_keys: reference_keys) - %w(registration_code)
    end
  end

  scope :filter_columns, lambda {|user:, action: ''|
    cols = readable_columns(user: user, action: action, reference_keys: false)
    next none if cols.empty?

    select(*cols)
  }

  scope :readable_records, lambda {|user:, action: ''|
    all
  }

  # method: GET
  scope :readables, lambda {|user:, action: ''|
    readable_records(user: user, action: action)
      .filter_columns(user: user, action: action)
  }
end
