class Notice < ActiveRecord::Base
  validates :title,   presence: true
  validates :text,    presence: true
  validates :pinned, inclusion: { in: [true, false] }

  validates :member,  presence: true
  belongs_to :member

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
    when ROLE_ID[:admin]
      true
    when ROLE_ID[:writer]
      member_id == by.id
    else # nologin, ...
      false
    end
  end

  def self.allowed_nested_params(user:)
    %w(member)
  end

  def self.readable_columns(user:, action: '')
    self.column_names
  end

  scope :filter_columns, ->(user:, action: '') {
    cols = readable_columns(user: user, action: action)
    next none if cols.empty?
    select(*cols)
  }

  scope :readable_records, ->(user:, action: '') {
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:participant], ROLE_ID[:viewer]
      all
    else # nologin, ...
      none
    end
  }

  # method: GET
  scope :readables, ->(user:, action: '') {
    readable_records(user: user, action: action)
      .filter_columns(user: user, action: action)
  }
end
