# [{1st_team_id, score, rank}, {2nd_team_id, score, rank}, {3rd_team_id, score, rank}, ...]
class Scoreboard
  delegate :map, to: :teams_scores

  def initialize(user:)
    # [{1st_team_id, score}, {2nd_team_id, score}, {3rd_team_id, score}, ...]
    @teams_scores = aggregate_each_team_score(user)

    return if teams_scores.blank?

    # 順位を付ける
    # 同点時の順位は 1 2 2 4
    current_rank = 1
    previous_score = teams_scores.first.fetch(:score)
    teams_scores.each.with_index(1) do |data, index|
      if previous_score != data[:score]
        previous_score = data[:score]
        current_rank = index
      end

      data[:rank] = current_rank
    end
  end

  def find_by_id(team_id)
    teams_scores.find {|data| data[:team_id] == team_id }
  end

  def count_same_rank(rank)
    teams_scores.count {|data| data[:rank] == rank }
  end

  private

  # for delegate
  attr_reader :teams_scores

  # { [team_id, problem_id] => [score, ...], ...}
  def collect_scores_of_team_and_problem(user)
    Score
      .readables(user: user, action: 'scoreboard')
      .joins(:answer)
      .select('answers.problem_id', 'answers.team_id', :point, 'answers.created_at', :answer_id)
      .group_by {|e| [e.team_id, e.problem_id] }
  end

  def aggregate_each_team_score(user)
    collect_scores_of_team_and_problem(user)
      .transform_values {|scores| scores.max_by {|score| score.answer.created_at } }
      .each_with_object(Hash.new(0)) {|(k, score), memo| memo[k[0]] += score.point }
      .sort_by {|e| -e[1] }
      .map {|e| { team_id: e[0], score: e[1] } }
  end
end
