class Comment < ActiveRecord::Base
  validates :text,    presence: true
  validates :member,  presence: true
  validates :commentable, presence: true

  belongs_to :member
  belongs_to :commentable, polymorphic: true

  def notification_payload(state: nil, **data)
    payload = super
    payload[:sub_resouce]    = payload[:resource]
    payload[:sub_resouce_id] = payload[:resource_id]
    payload.merge(
      resource: commentable_type,
      resource_id: commentable_id,  
    )
  end

  # method: POST
  def self.allowed_to_create_by?(user = nil, action: "")
    role_id = user&.role_id

    return true if role_id == ROLE_ID[:admin]

    case action
    when "issues_comments"
      return true if [ROLE_ID[:writer], ROLE_ID[:participant]].include? role_id
    when "problems_comments"
      return true if ROLE_ID[:writer] == role_id
    end

    false
  end

  # method: GET, PUT, PATCH, DELETE
  def allowed?(method:, by: nil, action: "")
    return self.class.readables(user: by, action: action).exists?(id: id) if method == "GET"

    role_id = by&.role_id

    return true if role_id == ROLE_ID[:admin]

    return false if action == "issues_comments"   && commentable_type != "Issue"
    return false if action == "problems_comments" && commentable_type != "Problem"

    return true if %w(issues_comments problems_comments).include?(action) && ROLE_ID[:writer] == role_id
    return true if action == "issues_comments" && ROLE_ID[:participant] == role_id &&
                   member.team == by.team && method != "DELETE"

    false
  end

  # method: GET
  scope :readables, ->(user: nil, action: "") {
    comments = case action
      when ""
        all
      when "issues_comments"
        where(commentable_type: "Issue")
      when "problems_comments"
        where(commentable_type: "Problem")
      else
        none
      end

    role_id = user&.role_id

    next comments if [ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:viewer]].include? role_id
    next none if ROLE_ID[:participant] != role_id

    # participant
    case action
    when "issues_comments"
      comments.joins(:member).where(members: { team: [user.team, nil] })
    when "problems_comments"
      comments
    else
      none
    end
  }

  private
    def commentable_type_check
      return if commentable_type.nil?
      unless %w(Problem Issue).include? commentable_type
        errors.add(:commentable, "specify problems or issues")
      end
    end
end
