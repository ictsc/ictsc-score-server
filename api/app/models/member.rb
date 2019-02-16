require 'sinatra/crypt_helpers'

class Member < ApplicationRecord
  include Sinatra::CryptHelpers
  extend Sinatra::CryptHelpers

  validates :name,            presence: true
  validates :login,           presence: true, uniqueness: true
  validates :hashed_password, presence: true
  validates :team,            presence: true, if: :participant?
  validates :role,            presence: true
  validates_associated :notification_subscriber

  has_many :marked_scores, foreign_key: 'marker_id', class_name: 'Score', dependent: :destroy
  has_many :created_problems, foreign_key: 'creator_id', class_name: 'Problem', dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notices, dependent: :destroy
  has_many :attachments, dependent: :destroy
  has_one :notification_subscriber, dependent: :destroy, as: :subscribable
  belongs_to :team
  belongs_to :role

  before_validation :build_notification_subscriber_if_not_exists

  attr_reader :password

  def build_notification_subscriber_if_not_exists
    build_notification_subscriber unless notification_subscriber
    notification_subscriber.valid?
  end

  def password=(value)
    return if value.blank? || same_password?(value)

    @password = value
    self.hashed_password = hash_password(@password)
  end

  def same_password?(plain_password)
    hashed_password.present? && compare_password(plain_password, hashed_password)
  end

  # method: POST
  def self.allowed_to_create_by?(user = nil, action: '')
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer], nil # nologin
      true
    else
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
    when ROLE_ID[:admin]
      true
    when ROLE_ID[:writer]
      readable?(by: by, action: action)
    when ROLE_ID[:participant]
      return false if method == 'DELETE'

      id == by.id
    else # nologin, ...
      false
    end
  end

  def self.allowed_nested_params(user:)
    %w(team)
  end

  def self.readable_columns(user:, action: '', reference_keys: true)
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer]
      all_column_names(reference_keys: reference_keys)
    when ROLE_ID[:viewer], ROLE_ID[:participant]
      all_column_names(reference_keys: reference_keys) - %w(hashed_password)
    else
      []
    end
  end

  scope :filter_columns, lambda {|user:, action: ''|
    cols = readable_columns(user: user, action: action, reference_keys: false)
    next none if cols.empty?

    select(*cols)
  }

  scope :readable_records, lambda {|user:, action: ''|
    case user&.role_id
    when ROLE_ID[:admin]
      all
    when ROLE_ID[:writer], ROLE_ID[:viewer]
      joins(:role).where('roles.id != ?', ROLE_ID[:admin])
    when ROLE_ID[:participant]
      joins(:role).where('roles.id = ?', ROLE_ID[:participant])
    else # nologin, ...
      none
    end
  }

  # method: GET
  scope :readables, lambda {|user:, action: ''|
    readable_records(user: user, action: action)
      .filter_columns(user: user, action: action)
  }

  def admin?
    role&.id == ROLE_ID[:admin]
  end

  def writer?
    role&.id == ROLE_ID[:writer]
  end

  def viewer?
    role&.id == ROLE_ID[:viewer]
  end

  def participant?
    role&.id == ROLE_ID[:participant]
  end

  def nologin?
    role.nil? || role&.id == ROLE_ID[:nologin]
  end

  def staff?
    admin? || writer? || viewer?
  end
end
