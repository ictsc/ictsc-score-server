class Scoreboard
  delegate :map, to: :teams_scores

  def initialize(user:)
    # [{1st_team, score}, {2nd_team, score}, {3rd_team, score}, ...]
    @teams_scores = collect_teams_scores(user)

    # [{1st_team, score, rank}, {2nd_team, score, rank}, {3rd_team, score, rank}, ...]
    rank!
  end

  def find_by_team(team)
    teams_scores.find {|data| data[:team] == team }
  end

  def count_same_rank(rank)
    teams_scores.count {|data| data[:rank] == rank }
  end

  private

  # for delegate
  attr_reader :teams_scores

  # { [team, problem_id] => [score, ...], ...}
  def collect_teams_scores(user)
    Score
      .readables(user: user, action: 'scoreboard')
      .preload(:answer, :team)
      .joins(:answer)
      .select('answers.problem_id', 'answers.team_id', :point, 'answers.created_at', :answer_id)
      .group_by(&:team)
      .map {|team, team_scores| { team: team, score: aggregate_team_score(team_scores) } }
  end

  # 各問題の最新の解答のスコアを集計する
  def aggregate_team_score(team_scores)
    team_scores
      .group_by(&:problem_id)
      .lazy
      .map {|problem_id, scores| scores.max_by {|s| s.answer.created_at } }
      .sum(&:point)
  end

  def rank!
    return if teams_scores.empty?

    teams_scores.sort_by! {|e| -e[:score] }
    teams_scores.first[:rank] = 1

    # 同点時の順位は 1 2 2 4
    teams_scores.each_cons(2).with_index(2) do |(previous_data, data), index|
      data[:rank] = (previous_data[:score] == data[:score]) ? previous_data[:rank] : index
    end
  end
end
