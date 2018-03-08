class Team < ActiveRecord::Base
  validates :name, presence: true
  validates :registration_code, presence: true
  validates_associated :notification_subscriber

  has_many :members, dependent: :nullify
  has_many :answers, dependent: :destroy
  has_many :issues, dependent: :destroy
  has_one :notification_subscriber, dependent: :destroy, as: :subscribable
  has_many :first_correct_answers, dependent: :nullify

  before_validation def build_notification_subscriber_if_not_exists
    build_notification_subscriber if not notification_subscriber
  end

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

  # method: GET
  scope :readables, ->(user:, action: "") {
    all
  }
end
