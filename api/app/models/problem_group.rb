class ProblemGroup < ApplicationRecord
  validates :name, presence: true
  validates :description, presence: false, allow_nil: false, length: { maximum: 4095 }
  validates :order, presence: true
  validates :visible, inclusion: { in: [true, false] }
  validates :completing_bonus_point, presence: true
  validates :icon_url, presence: false, length: { maximum: 4095 }

  has_and_belongs_to_many :problems, dependent: :nullify

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
    %w(problems)
  end

  def self.readable_columns(user:, action: '', reference_keys: true)
    all_column_names(reference_keys: reference_keys)
  end

  scope :filter_columns, lambda {|user:, action: ''|
    cols = readable_columns(user: user, action: action, reference_keys: false)
    next none if cols.empty?

    select(*cols)
  }

  scope :readable_records, lambda {|user:, action: ''|
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:viewer]
      all
    when ROLE_ID[:participant]
      next none unless in_competition?

      all
    else # nologin, ...
      none
    end
  }

  # method: GET
  scope :readables, lambda {|user:, action: ''|
    readable_records(user: user, action: action)
      .filter_columns(user: user, action: action)
  }
end
