ROLE_ID = {
  admin: 2,
  writer: 3,
  participant: 4,
  viewer: 5,
  nologin: 1,
}

class ActiveRecord::Base
  def self.required_fields(options = {})
    options[:include] ||= []
    options[:include].map!(&:to_sym)

    options[:exclude] ||= []
    options[:exclude].map!(&:to_sym)

    fields = self.validators
                 .select{|x| ActiveRecord::Validations::PresenceValidator === x }
                 .map(&:attributes)
                 .flatten
    fields - options[:exclude] + options[:include]
  end
end

class Team < ActiveRecord::Base
  validates :name, presence: true
  validates :registration_code, presence: true

  has_many :members, dependent: :nullify
  has_many :answers, dependent: :destroy
  has_many :issues, dependent: :destroy

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
    when ROLE_ID[:admin], ROLE_ID[:writer]
      true
    else # nologin, ...
      false
    end
  end

  # method: GET
  scope :readables, ->(user: nil, action: "") {
    all
  }
end

class Role < ActiveRecord::Base
  validates :name, presence: true
  validates :rank, presence: true

  has_many :members

  # method: POST
  def self.allowed_to_create_by?(user = nil, action: "")
    case user&.role_id
    when ROLE_ID[:admin]
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
    else # nologin, ...
      false
    end
  end

  # method: GET
  scope :readables, ->(user: nil, action: "") {
    case user&.role_id
    when ROLE_ID[:admin]
      all
    when ROLE_ID[:writer]
      where("rank >= ?", user.role.rank)
    when nil # nologin
      where("id = ?", ROLE_ID[:participant])
    else # nologin, ...
      false
    end
  }
end

class Member < ActiveRecord::Base
  validates :name,            presence: true
  validates :login,           presence: true, uniqueness: true
  validates :hashed_password, presence: true
  validates :team,            presence: true, if: Proc.new {|member| not member.team_id.nil? }
  validates :team,            presence: true, on: :sign_up
  validates :role,            presence: true

  has_many :marked_scores   , foreign_key: "marker_id" , class_name: "Score"  , dependent: :destroy
  has_many :created_problems, foreign_key: "creator_id", class_name: "Problem", dependent: :destroy

  has_many :comments, dependent: :destroy
  has_many :notices, dependent: :destroy
  has_many :attachments, dependent: :destroy

  belongs_to :team
  belongs_to :role

  # method: POST
  def self.allowed_to_create_by?(user = nil, action: "")
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer], nil # nologin
      true
    else
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
      self.class.readables(user: by, action: action).exists?(id: id)
    when ROLE_ID[:participant]
      return false if method == "DELETE"
      id == by.id
    else # nologin, ...
      false
    end
  end

  # method: GET
  scope :readables, ->(user: nil, action: "") {
    case user&.role_id
    when ROLE_ID[:admin]
      all
    when ROLE_ID[:writer], ROLE_ID[:participant], ROLE_ID[:viewer]
      joins(:role).where("roles.rank >= ?", user.role.rank)
    else # nologin, ...
    end
  }
end

class Problem < ActiveRecord::Base
  validates :title,     presence: true
  validates :text,      presence: true
  validates :creator,   presence: true
  validates :reference_point, presence: true
  validates :perfect_point,   presence: true

  has_many :answers,  dependent: :destroy
  has_many :comments, dependent: :destroy, as: :commentable
  has_many :issues,   dependent: :destroy
  has_many :next_problems, class_name: self.to_s, foreign_key: "problem_must_solve_before_id"

  belongs_to :problem_group
  belongs_to :problem_must_solve_before, class_name: self.to_s
  belongs_to :creator, foreign_key: "creator_id", class_name: "Member"

  # method: POST
  def self.allowed_to_create_by?(user = nil, action: "")
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer]
      true
    else
      false
    end
  end

  # method: GET, PUT, PATCH, DELETE
  def allowed?(by: nil, method:, action: "")
    return self.class.readables(user: by, action: action).exists?(id: id) if method == "GET"

    case by&.role_id
    when ROLE_ID[:admin]
      true
    when ROLE_ID[:writer]
      creator_id == by.id
    else
      false
    end
  end

  # method: GET
  scope :readables, ->(user: nil, action: "") {
    case user&.role_id
    when ROLE_ID[:admin]
      all
    when ROLE_ID[:writer]
      next all if action.empty?
      next where(creator: user) if action == "problems_comments"
      none
    when ROLE_ID[:participant]
      relation =
        left_outer_joins(problem_must_solve_before: [answers: [:score]]).
        group(:id).
        where(answers: {team: [user.team, nil]})

      relation.
        having(problem_must_solve_before_id: nil).
        or(relation.having(Score.arel_table[:point].sum.gteq(
          Problem.arel_table.alias("problem_must_solve_befores_problems")[:reference_point])
        ))
    when ROLE_ID[:viewer]
      all
    else
      none
    end
  }
end

class ProblemGroup < ActiveRecord::Base
  validates :name,     presence: true

  has_many :problems, dependent: :nullify

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
    when ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:participant], ROLE_ID[:viewer]
      true
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

class Issue < ActiveRecord::Base
  validates :title,   presence: true
  validates :problem, presence: true
  validates :team, presence: true
  validates :closed, inclusion: { in: [true, false] }

  has_many :comments, dependent: :destroy, as: :commentable

  belongs_to :problem
  belongs_to :team

  # method: POST
  def self.allowed_to_create_by?(user = nil, action: "")
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:participant]
      true
    else # nologin, ...
      false
    end
  end

  # method: GET, PUT, PATCH, DELETE
  def allowed?(method:, by: nil, action: "")
    return self.class.readables(user: by, action: action).exists?(id: id) if method == "GET"

    case by&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer]
      true
    when ROLE_ID[:participant]
      return false if method == "DELETE"
      team_id == by.team_id
    else # nologin, ...
      false
    end
  end

  # method: GET
  scope :readables, ->(user: nil, action: "") {
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:viewer]
      all
    when ROLE_ID[:participant]
      where(team: user.team)
    else # nologin, ...
      none
    end
  }
end

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

class Answer < ActiveRecord::Base
  validates :problem, presence: true
  validates :score,   presence: true, if: Proc.new {|answer| not answer&.score&.id.nil? }

  has_many :comments, dependent: :destroy, as: :commentable

  belongs_to :problem
  has_one :score
  belongs_to :team

  # method: POST
  def self.allowed_to_create_by?(user = nil, action: "")
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:participant]
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
    when ROLE_ID[:participant]
      return false if method != "PATCH"
      team_id == by.team_id
    else # nologin, ...
      false
    end
  end

  # method: GET
  scope :readables, ->(user: nil, action: "") {
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:viewer]
      all
    when ROLE_ID[:participant]
      where(team: user.team)
    else # nologin, ...
      none
    end
  }
end

class Score < ActiveRecord::Base
  validates :point,  presence: true
  validates :answer, presence: true, uniqueness: true
  validates :marker, presence: true

  belongs_to :answer
  belongs_to :marker, foreign_key: "marker_id", class_name: "Member"

  def problem
    # answer.problem と等価
    Problem.joins(:answers).where(answers: {id: answer_id}).first
  end

  def firstblood?
    self == Score.joins(:answer).where(answers: {problem_id: self.problem.id}).order("answers.created_at").first
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

  # method: GET, PUT, PATCH, DELETE
  def allowed?(method:, by: nil, action: "")
    return self.class.readables(user: by, action: action).exists?(id: id) if method == "GET"

    case by&.role_id
    when ROLE_ID[:admin]
      true
    when ROLE_ID[:writer]
      marker_id == by.id
    else # nologin, ...
      false
    end
  end

  # method: GET
  scope :readables, ->(user: nil, action: "") {
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:viewer]
      all
    when ROLE_ID[:participant]
      parameters = { team_id: 3, time: DateTime.now - 1200.seconds } # TODO: read from config
      joins(:answer).where("answers.team_id = :team_id AND scores.updated_at <= :time", parameters)
    else # nologin, ...
      none
    end
  }
end

class Comment < ActiveRecord::Base
  validates :text,    presence: true
  validates :member,  presence: true
  validates :commentable, presence: true

  belongs_to :member
  belongs_to :commentable, polymorphic: true

  # method: POST
  def self.allowed_to_create_by?(user = nil, action: "")
    role_id = user&.role_id

    return true if role_id == ROLE_ID[:admin]

    case action
    when "issues_comments"
      return true if [ROLE_ID[:writer], ROLE_ID[:participant]].include? role_id
    when "answers_comments"
      return true if ROLE_ID[:participant] == role_id
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
    return false if action == "answers_comments"  && commentable_type != "Answer"
    return false if action == "problems_comments" && commentable_type != "Problem"

    return true if %w(issues_comments problems_comments).include? action && ROLE_ID[:writer] == role_id
    return true if %w(issues_comments answers_comments).include? action && ROLE_ID[:participant] == role_id &&
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
      when "answers_comments"
        where(commentable_type: "Answer")
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
    when "answers_comments"
      comments.joins(:member).where(members: { team: user.team })
    when "problems_comments"
      comments
    else
      none
    end
  }

  private
    def commentable_type_check
      return if commentable_type.nil?
      unless %w(Problem Issue Answer).include? commentable_type
        errors.add(:commentable, "specify one of problems, issues or answers")
      end
    end
end

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

    case user&.role_id
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
