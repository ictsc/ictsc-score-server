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
      joins(:answer).where("answers.team_id = :team_id AND answers.completed_at <= :time", parameters)
    else # nologin, ...
      none
    end
  }
end
