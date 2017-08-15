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

  # self が、チームにて問題グループ全ての基準を満たした最初の解答かどうか
  def cleared_problem_group_bonus
    answer = self.answer
    problem_groups = answer.problem.problem_groups

    return 0 if problem_groups.empty?

    problem_groups.map do |problem_group|
      # pg: problem_group
      problems_count_in_pg = problem_group.problems.count

      relation_problems_solved = Score \
        .joins(answer: { problem: { problem_groups: {}}}) \
        .where(answers: { team_id: answer.team_id, problems: { problem_groups: { id: problem_group.id } } }) \
        .group('problems.id', 'problem_groups.id') \
        .having('sum(scores.point) >= problems.reference_point') \
        .select('problem_groups.id', 'problems.reference_point')

      problems_solved_count = relation_problems_solved.where("scores.id <= ?", self.id).to_a.count

      # if this score doesn't make all problems in pg cleared yet, return false
      next 0 if problems_solved_count != problems_count_in_pg

      # if this score before than self have solved all problems in pg, return false
      problems_solved_before_self_count = relation_problems_solved.where("scores.id < ?", self.id).to_a.count

      next 0 if problems_solved_before_self_count == problems_solved_count

      problem_group.completing_bonus_point
    end.sum
  end

  # @return { team_id: { problem_group_id: completing_bonus_point } }  (when with_tid: true)
  # @return { problem_group_id: completing_bonus_point }               (when with_tid: false)
  def self.cleared_problem_group_bonuses(team_id: nil, with_tid: false)
    # reference_points[problem_group_id][problem_id] = reference_point
    reference_points = Problem.joins(:problem_groups) \
      .all \
      .pluck(:problem_group_id, :id, :reference_point) \
      .inject({}) do |acc, (pgid, id, ref)|
        acc[pgid] ||= {}
        acc[pgid][id] ||= {}
        acc[pgid][id] = ref
        acc
      end

    subtotal_point = {} # [team_id][problem_id]
    score_id_with_bonus = {} # [team_id][score_id][problem_group_id] = completing_bonus_point or 0

    score_relation = team_id.nil? ? Score : Score.joins(:answer).where(answers: { team_id: team_id })
    score_relation.joins(answer: { problem: { problem_groups: {} } }) \
      .order(:id) \
      .pluck('id', 'team_id', 'answers.problem_id', 'scores.point', 'problem_groups_problems.problem_group_id', 'problem_groups.completing_bonus_point') \
      .each do |(score_id, team_id, problem_id, point, pg_id, pg_bonus_point)|
        subtotal_point[team_id] ||= Hash.new(0)
        score_id_with_bonus[team_id] ||= {}
        score_id_with_bonus[team_id][score_id] ||= {}

        next if score_id_with_bonus[team_id][score_id][pg_id]

        subtotal_point[team_id][problem_id] += point
        score_id_with_bonus[team_id][score_id][pg_id] ||= pg_bonus_point if reference_points[pg_id].all?{|(problem_id, ref)| ref <= subtotal_point[team_id][problem_id] }
      end
    create_hash = proc do |hash|
      hash&.map{|score_id, pg_id_bonus_hash| [score_id, pg_id_bonus_hash.values.inject(:+) ] }&.to_h&.compact || {}
    end

    if with_tid
      score_id_with_bonus.map{|team_id, hash| [team_id, create_hash.call(score_id_with_bonus[team_id])] }.to_h
    elsif team_id
      create_hash.call(score_id_with_bonus[team_id])
    else
      create_hash.call(score_id_with_bonus.values.inject(&:merge))
    end
  end

  def bonus_point
    cleared_problem_group_bonus
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
      joins(:answer).where("answers.team_id = :team_id AND answers.created_at <= :time", parameters)
    else # nologin, ...
      none
    end
  }
end
