# frozen_string_literal: true

require 'matrix'

# 概要ページ, 得点シート出力用
class ReportCard
  class << self
    def readables(team:) # rubocop:disable Metrics/MethodLength
      return [] if team.player?

      problems = sorted_problems
      # スコアボードの表示結果と完全に同じにする
      records = Scoreboard.readables(team: team)
      # ScoreAggregator.aggregate_penalties(penalties: Penalty.all)

      records.each do |record|
        record[:each_score] = problems.map do |pb|
          record[:answers]
            .find {|answer| answer.problem_id == pb.id }
            &.score
            &.point
        end

        record[:each_percent] = problems.map do |pb|
          record[:answers]
            .find {|answer| answer.problem_id == pb.id }
            &.score
            &.percent
        end

        # 満点や平均点のチームを表現するためにteamを分解する
        record[:team_name] = record[:team].name
        record[:team_organization] = record[:team].organization

        record.delete(:answers)
        record.delete(:team)
      end

      # 互いの計算に影響しないように注意
      max_record = build_max_record(problems: problems)
      avg_record = build_avg_record(records: records)
      records.push(max_record)
      records.push(avg_record)

      records.each {|record| assign_default_value(record: record) }

      records
    end

    private

    def sorted_problems
      # カテゴリ未所属対応
      Problem
        .includes(:body, :category)
        .all
        .sort_by {|pb| [pb.category&.order || -1, pb.order] }
    end

    def build_max_record(problems:)
      {
        team_name: '満点',
        score: problems.sum {|pb| pb.body.perfect_point },
        each_score: problems.map {|pb| pb.body.perfect_point },
        problem_titles: problems.map {|pb| pb.body.title },
        problem_genres: problems.map {|pb| pb.body.genre }
      }
    end

    def build_avg_record(records:)
      {
        team_name: '平均',
        score: records.sum {|record| record[:score] } / records.size,
        each_score: build_each_score_avg(records: records)
      }
    end

    def build_each_score_avg(records:)
      # 未提出はカウントしない
      Matrix[*records.map {|record| record[:each_score] }]
        .column_vectors
        .map {|column| column.select(&:present?) }
        .map {|column| column.size.zero? ? nil : (column.sum / column.size) }
    end

    def assign_default_value(record:)
      record[:team_organization] = '' if record[:team_organization].nil?
      record[:rank] = nil if record[:rank].nil?

      record[:each_percent] = [] if record[:each_percent].nil?
      record[:problem_titles] = [] if record[:problem_titles].nil?
      record[:problem_genres] = [] if record[:problem_genres].nil?
    end
  end
end
