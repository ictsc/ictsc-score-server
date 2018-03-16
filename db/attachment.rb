class Attachment < ActiveRecord::Base
  validates :filename, presence: true

  belongs_to :member

  # method: POST
  def self.allowed_to_create_by?(user = nil, action: "")
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer]
      true
    when ROLE_ID[:participant]
      in_competition?
    else # nologin, ...
      false
    end
  end

  def readable?(by: nil, action: '')
    self.class.readables(user: by, action: action).exists?(id: id)
  end

  # method: GET, DELETE
  def allowed?(method:, by: nil, action: "")
    return readable?(by: by, action: action) if method == 'GET'

    case by&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer]
      true
    when ROLE_ID[:participant]
      member_id == by.id
    else # nologin, ...
      false
    end
  end

  def self.readable_columns(user:, action: '')
    self.column_names
  end

  scope :filter_columns, ->(user:, action: '') {
    cols = readable_columns(user: user, action: action)
    next none if cols.empty?
    select(*cols)
  }

  # method: GET
  scope :readable_records, ->(user:, action: '') {
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer]
      all
    when ROLE_ID[:participant]
      next none unless in_competition?
      where(member: user)
    when ROLE_ID[:viewer]
      all
    else # nologin, ...
      none
    end
  }
end
