class Score < ApplicationRecord
  validates :point,  presence: true
  validates :answer, presence: true, uniqueness: true
  validates :marker, presence: true

  belongs_to :answer
  belongs_to :marker, foreign_key: "marker_id", class_name: "Member"

  after_save :refresh_first_correct_answer

  def notification_payload(state: :created, **data)
    payload = super
    payload[:data].merge!(
      problem_id: answer.problem_id,
      team_id: answer.team_id,
      created_at: answer.created_at,
      notify_at: answer.created_at + Setting.answer_reply_delay_sec
      )
    payload
  end

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

      # TODO: solved flag
      relation_problems_solved = Score
        .joins(answer: { problem: { problem_groups: {}}})
        .where(answers: { team_id: answer.team_id, problems: { problem_groups: { id: problem_group.id } } })
        .group('problems.id', 'problem_groups.id')
        .having('sum(scores.point) >= problems.reference_point')
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
    # TODO: solved flag
    # reference_points[problem_group_id][problem_id] = reference_point
    reference_points = Problem.joins(:problem_groups)
      .all
      .pluck(:problem_group_id, :id, :reference_point)
      .inject({}) do |acc, (pgid, id, ref)|
        acc[pgid] ||= {}
        acc[pgid][id] ||= {}
        acc[pgid][id] = ref
        acc
      end

    subtotal_point = {} # [team_id][problem_id]
    score_id_with_bonus = {} # [team_id][score_id][problem_group_id] = completing_bonus_point or 0

    score_relation = team_id.nil? ? Score : Score.joins(:answer).where(answers: { team_id: team_id })
    score_relation.joins(answer: { problem: { problem_groups: {} } })
      .order(:id)
      .pluck('id', 'team_id', 'answers.problem_id', 'scores.point', 'problem_groups_problems.problem_group_id', 'problem_groups.completing_bonus_point')
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

  def refresh_first_correct_answer
    problem = answer.problem
    team = answer.team
    if answer.score.solved
      FirstCorrectAnswer.create!(team: team, problem: problem, answer: answer) unless FirstCorrectAnswer.where(team: team, problem: problem).first
    else
      # 採点修正
      fca = FirstCorrectAnswer.where(team: team, problem: problem).first
      if fca
        fca.destroy
        ans = Answer.where(team: team, problem: problem).joins(:score).where(scores: {solved: true}).order(:created_at).first
        FirstCorrectAnswer.create!(team: team, problem: problem, answer: ans) if ans
      end
    end
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
      marker_id == by.id
    else # nologin, ...
      false
    end
  end

  def self.allowed_nested_params(user:)
    base_params = %w(answer)
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:viewer]
      base_params + %w(answer-problem)
    when ROLE_ID[:participant]
      base_params
    else
      %w()
    end
  end

  def self.readable_columns(user:, action: '', reference_keys: true)
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:viewer]
      self.all_column_names(reference_keys: reference_keys)
    when ROLE_ID[:participant]
      self.all_column_names(reference_keys: reference_keys) - %w(marker_id)
    else # nologin, ...
      %w()
    end
  end

  scope :filter_columns, ->(user:, action: '') {
    cols = readable_columns(user: user, action: action, reference_keys: false)
    next none if cols.empty?
    select(*cols)
  }

  # actionを'aggregate'にするとスコアボードからの集計用に競技者でも全チームの得点を参照できる
  scope :readable_records, ->(user:, action: '') {
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer], ROLE_ID[:viewer]
      all
    when ROLE_ID[:participant]
      next none unless in_competition?

      rel = joins(:answer).merge(Answer.reply_delay)

      case action
      when 'aggregate'
        rel
      else
        rel.where(answers: { team: user.team })
      end
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

# [{1st_team_id, score, rank}, {2nd_team_id, score, rank}, {3rd_team_id, score, rank}, ...]
class Score::Scores < Array
  def initialize(user:)
    super()

    # [{1st_team_id, score}, {2nd_team_id, score}, {3rd_team_id, score}, ...]
    data = Score
      .readables(user: user, action: 'aggregate')
      .joins(:answer)
      .select("answers.problem_id", "answers.team_id", :point, "answers.created_at", :answer_id)
      .to_a
      .group_by{|e| [e.team_id, e.problem_id]}

    data
      .each{|key, score| data[key] = score.max_by{|s| s.answer.created_at}}
      .inject(Hash.new(0)){|memo, (k, v)| memo[k[0]] += v.point; memo}
      .to_a
      .sort_by{|e| e[1]}
      .reverse
      .map{|e| self.push({team_id: e[0], score: e[1]})}

    # 順位を付ける
    # 同スコアがあった場合の順位は 1 2 2 4
    current_rank = 1
    previous_score = self.first&.fetch(:score)
    self.each.with_index(1) do |data, index|
      if previous_score != data[:score]
        previous_score = data[:score]
        current_rank = index
      end

      data[:rank] = current_rank
    end
  end

  def find_by_id(team_id)
    self.find{|data| data[:team_id] == team_id }
  end

  def count_same_rank(rank)
    self.count{|data| data[:rank] == rank }
  end
end
