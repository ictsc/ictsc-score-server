# Make settings could be read via `Setting.hogefuga`
class Setting
  include Singleton

  ENV_PREFIX = 'API_CONTEST_'
  REQUIRED_KEYS = %w(
    answer_reply_delay_sec
    first_blood_bonus_percentage
    bonus_point_for_clear_problem_group
    competition_start_at
    scoreboard_hide_at
    competition_end_at
  )

  INTEGER_VALUES = %w(
    answer_reply_delay_sec
    first_blood_bonus_percentage
    bonus_point_for_clear_problem_group
  )

  DATETIME_VALUES = %w(
    competition_start_at
    scoreboard_hide_at
    competition_end_at
  )

  REQUIRED_KEYS.each do |key|
    env_key = ENV_PREFIX + key.upcase

    begin
      env_value = ENV.fetch(env_key)
    rescue KeyError
      STDERR.puts "ENV '#{env_key}' not defined, aborting."
      exit 1
    end

    value = case key
      when *INTEGER_VALUES then env_value.to_i
      when *DATETIME_VALUES then DateTime.parse(env_value)
      else env_value
      end

    define_singleton_method(key.to_sym) { value }
  end
end

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
                 .reject{|x| x.options[:if] }
                 .flat_map(&:attributes)
                 .map do |x|
                   reflection = self.reflections[x.to_s]
                   if reflection&.kind_of?(ActiveRecord::Reflection::BelongsToReflection)
                     reflection.foreign_key.to_sym
                   else
                     x
                   end
                 end

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
      none
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

  # For FactoryGirl to pass plain password to spec from factory
  attr_accessor :password 

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
      none
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
    return self.class.readables(user: by, action: action).to_a.one?{|x| x.id == id } if method == "GET"

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
      next none if DateTime.now <= Setting.competition_start_at

      relation =
        left_outer_joins(problem_must_solve_before: [answers: [:score]]).
        group(:id).
        where(answers: {team: [user.team, nil]})

      relation.
        having(problem_must_solve_before_id: nil).
        or(relation.having(Score.arel_table[:point].sum.gteq(
          Problem.arel_table.alias("problem_must_solve_befores_problems")[:reference_point])
        )).
        select("problem_must_solve_befores_problems.*, problems.*")
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
    when ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:viewer]
      all
    when ROLE_ID[:participant]
      next none if DateTime.now <= Setting.competition_start_at
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
  validates :team,    presence: true
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
    self.class.firstbloods(only_ids: true).include? self.id
  end

  # self が、チームにて問題グループ全ての基準を満たした最初の解答かどうか
  def cleared_problem_group?
    answer = self.answer
    problem_group_id = answer.problem.problem_group_id

    return false if problem_group_id.nil?

    # pg: problem_group

    problems_count_in_pg = Problem.where(problem_group_id: problem_group_id).count

    relation_problems_solved = Score \
      .joins(answer: { problem: { problem_group: {}}}) \
      .where(answers: {team_id: answer.team_id}, problems: {problem_group_id: problem_group_id}) \
      .group(:problem_id, :problem_group_id) \
      .having("sum(scores.point) >= problems.reference_point") \
      .select(:problem_group_id, "problems.reference_point") # select `problems.reference_point` for MySQL

    problems_solved_count = relation_problems_solved.where("scores.id <= ?", self.id).to_a.count

    # if this score doesn't make all problems in pg cleared yet, return false
    return false if problems_solved_count != problems_count_in_pg

    # if this score before than self have solved all problems in pg, return false
    problems_solved_before_self_count = relation_problems_solved.where("scores.id < ?", self.id).to_a.count
    return problems_solved_before_self_count != problems_solved_count
  end

  alias_method :is_firstblood, :firstblood?

  # return all firstblood scores
  def self.firstbloods(only_ids: false)
    join_table = Arel::Table.new("table") # "table" doesn't mean anything
    scores     = Score.arel_table
    answers    = Answer.arel_table
    problems   = Problem.arel_table
    a_before   = Answer.arel_table.alias("a_before")
    s_before   = Score.arel_table.alias("s_before")

    join_tables = [
      join_table.join(answers).on(scores[:answer_id].eq(answers[:id])),
      join_table.join(problems).on(answers[:problem_id].eq(problems[:id])),
      join_table.join(a_before).on(
        a_before[:problem_id].eq(problems[:id]),
        a_before[:team_id].eq(answers[:team_id]),
        a_before[:completed_at].lteq(answers[:completed_at])
      ),
      join_table.join(s_before).on(s_before[:answer_id].eq(a_before[:id]))
    ].map(&:join_sources)

    ids_by_problem_id = Score \
      .joins(*join_tables) \
      .group(answers[:id], "problems.reference_point") \
      .having(problems[:reference_point].lteq(s_before[:point].sum)) \
      .order(answers[:completed_at]) \
      .pluck("answers.problem_id", "scores.id") \
      .inject({}){|acc, (p_id, id)| acc[p_id] ||= id; acc }

    if only_ids
      ids_by_problem_id.values
    else
      Score.where(id: ids_by_problem_id.values)
    end
  end

  def self.cleared_problem_group_ids(team_id: nil, with_tid: false)
    # reference_points[pgid][id] = referenec_point
    reference_points = Problem \
      .all \
      .pluck(:problem_group_id, :id, :reference_point) \
      .inject({}) do |acc, (pgid, id, ref)|
        acc[pgid] ||= {}
        acc[pgid][id] ||= {}
        acc[pgid][id] = ref
        acc
      end

    total_problems_by_pg = Problem.all.group(:problem_group_id).count
    subtotal_point = {} # [tid][pid]
    score_id_cleared_pg = {} # [tid][pgid]

    relation = team_id.nil? ? Score : Score.joins(:answer).where(answers: { team_id: team_id })

    relation.includes(answer: { problem: {} }).order(:id).each do |x|
      tid = x.answer.team_id
      pid = x.answer.problem.id
      pgid = x.answer.problem.problem_group_id

      subtotal_point[tid] ||= Hash.new(0)
      score_id_cleared_pg[tid] ||= {}

      next if score_id_cleared_pg[tid][pgid]

      subtotal_point[tid][pid] += x.point
      score_id_cleared_pg[tid][pgid] = x.id if reference_points[pgid].all?{|(pid, ref)| ref <= subtotal_point[tid][pid] }
    end

    return Hash[score_id_cleared_pg.map{|k, v| [k, v.values] }] if with_tid
    return score_id_cleared_pg.values.flat_map(&:values)
  end

  def bonus_point
    bonus = 0

    bonus += (self.answer.problem.perfect_point * Setting.first_blood_bonus_percentage / 100.0) if firstblood?
    bonus += Setting.bonus_point_for_clear_problem_group if cleared_problem_group?

    bonus
  end

  def subtotal_point
    point + bonus_point
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
      next none if Setting.competition_end_at <= DateTime.now
      parameters = { team_id: user.team.id, time: DateTime.now - Setting.answer_reply_delay_sec.seconds }
      joins(:answer).where("answers.team_id = :team_id AND answers.updated_at <= :time", parameters)
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
