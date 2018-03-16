class Comment < ActiveRecord::Base
  validates :text,    presence: true
  validates :member,  presence: true
  validates :commentable, presence: true

  belongs_to :member
  belongs_to :commentable, polymorphic: true

  def notification_payload(state: :created, **data)
    payload = super
    payload[:type] = "#{commentable_type.downcase}-comment"
    payload[:data].merge!("#{commentable_type.downcase}_id" => commentable_id)

    if commentable_type == "Issue"
      payload[:data].merge!(problem_id: commentable.problem_id, team_id: commentable.team_id)
    end

    payload
  end

  # method: POST
  def self.allowed_to_create_by?(user = nil, action: "")
    role_id = user&.role_id

    return true if role_id == ROLE_ID[:admin]
    return false if role_id == ROLE_ID[:participant] && !in_competition?

    case action
    when "issues_comments"
      return true if [ROLE_ID[:writer], ROLE_ID[:participant]].include? role_id
    when "problems_comments"
      return true if ROLE_ID[:writer] == role_id
    end

    false
  end

  def readable?(by: nil, action: '')
    self.class.readables(user: by, action: action).exists?(id: id)
  end

  # method: GET, PUT, PATCH, DELETE
  def allowed?(method:, by: nil, action: "")
    return readable?(by: by, action: action) if method == 'GET'

    role_id = by&.role_id

    return true if role_id == ROLE_ID[:admin]

    return false if action == "issues_comments"   && commentable_type != "Issue"
    return false if action == "problems_comments" && commentable_type != "Problem"

    return true if %w(issues_comments problems_comments).include?(action) && ROLE_ID[:writer] == role_id
    return true if action == "issues_comments" && ROLE_ID[:participant] == role_id &&
                   member.team == by.team && method != "DELETE"

    false
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

  # method: GET
  scope :readables, ->(user:, action: "") {
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

    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:viewer]
      comments
    when ROLE_ID[:participant]
      next none unless in_competition?

      case action
      when "issues_comments"
        comments.joins(:member).where(members: { team: [user.team, nil] })
      when "problems_comments"
        comments
      else
        none
      end
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
