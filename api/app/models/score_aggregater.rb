# [{1st_team_id, score, rank}, {2nd_team_id, score, rank}, {3rd_team_id, score, rank}, ...]
class ScoreAggregater < Array
  def initialize(user:) # rubocop:disable Metrics/MethodLength
    super()

    # [{1st_team_id, score}, {2nd_team_id, score}, {3rd_team_id, score}, ...]
    tmp_data = Score
      .readables(user: user, action: 'aggregate')
      .joins(:answer)
      .select('answers.problem_id', 'answers.team_id', :point, 'answers.created_at', :answer_id)
      .to_a
      .group_by {|e| [e.team_id, e.problem_id] }

    tmp_data
      .each {|key, score| tmp_data[key] = score.max_by {|s| s.answer.created_at } }
      .each_with_object(Hash.new(0)) {|(k, v), memo| memo[k[0]] += v.point }
      .to_a
      .sort_by {|e| e[1] }
      .reverse
      .map {|e| push({ team_id: e[0], score: e[1] }) }

    # 順位を付ける
    # 同スコアがあった場合の順位は 1 2 2 4
    current_rank = 1
    previous_score = first&.fetch(:score)
    each.with_index(1) do |data, index|
      if previous_score != data[:score]
        previous_score = data[:score]
        current_rank = index
      end

      data[:rank] = current_rank
    end
  end

  def find_by_id(team_id)
    find {|data| data[:team_id] == team_id }
  end

  def count_same_rank(rank)
    count {|data| data[:rank] == rank }
  end
end
