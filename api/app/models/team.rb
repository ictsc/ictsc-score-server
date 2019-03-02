require 'sinatra/crypt_helpers'

class Team < ApplicationRecord
  include Sinatra::CryptHelpers
  extend Sinatra::CryptHelpers

  validates :name, presence: true
  validates :organization, presence: false
  validates :hashed_registration_code, presence: true
  validates_associated :notification_subscriber
  validate :validate_registration_code_uniqueness, if: :will_save_change_to_registration_code?

  has_many :members, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :issues, dependent: :destroy
  has_many :first_correct_answers, dependent: :destroy
  has_one :notification_subscriber, dependent: :destroy, as: :subscribable

  before_validation :build_notification_subscriber_if_not_exists

  attr_reader :registration_code

  def build_notification_subscriber_if_not_exists
    build_notification_subscriber unless notification_subscriber
  end

  def will_save_change_to_registration_code?
    new_record? || will_save_change_to_hashed_registration_code?
  end

  def validate_registration_code_uniqueness
    if registration_code.blank?
      errors.add(:registration_code, 'should not be blank')
      return false
    end

    if self.class.registration_code_exists?(registration_code)
      errors.add(:registration_code, 'already exists')
      return false
    end

    true
  end

  def registration_code=(value)
    return if value.blank? || same_registration_code?(value)

    @registration_code = value
    self.hashed_registration_code = hash_password(@registration_code)
  end

  def same_registration_code?(code)
    hashed_registration_code.present? && compare_password(code, hashed_registration_code)
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
      all_column_names(reference_keys: reference_keys) - %w(hashed_registration_code)
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

  def self.find_by_registration_code(registration_code)
    find {|team| compare_password(registration_code, team.hashed_registration_code) }
  end

  def self.registration_code_exists?(registration_code, ignore: nil)
    raise ArgumentError, 'registration_code should not be blank' if registration_code.blank?

    Team.pluck(:hashed_registration_code).any? {|hash| compare_password(registration_code, hash) }
  end
end
