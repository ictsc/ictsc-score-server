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

  # method: GET, PUT, PATCH, DELETE
  def allowed?(method:, by: nil, action: "")
    return self.class.readables(user: by, action: action).exists?(id: id) if method == "GET"

    case by&.role_id
    when ROLE_ID[:admin]
      true
    when ROLE_ID[:writer]
      member_id == by.id
    else # nologin, ...
      false
    end
  end

  # method: GET
  scope :readables, ->(user: nil, action: "") {
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:participant], ROLE_ID[:viewer]
      all
    else # nologin, ...
      none
    end
  }
end
