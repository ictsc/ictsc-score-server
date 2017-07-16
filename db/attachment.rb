class Attachment < ActiveRecord::Base
  validates :filename, presence: true

  belongs_to :member

  # method: POST
  def self.allowed_to_create_by?(user = nil, action: "")
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:participant]
      true
    else # nologin, ...
      false
    end
  end

  # method: GET, DELETE
  def allowed?(method:, by: nil, action: "")
    return self.class.readables(user: by, action: action).exists?(id: id) if method == "GET"

    case by&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer]
      true
    when ROLE_ID[:participant]
      member_id == by.id
    else # nologin, ...
      false
    end
  end

  # method: GET
  scope :readables, ->(user: nil, action: "") {
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer]
      all
    when ROLE_ID[:participant]
      where(member: user)
    when ROLE_ID[:viewer]
      all
    else # nologin, ...
      none
    end
  }
end
