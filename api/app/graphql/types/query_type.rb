# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :me,                   Types::TeamType,                 null: true
    field :contest_info,         Types::ContestInfoType,          null: false
    field :attachments,          [Types::AttachmentType],         null: false
    field :categories,           [Types::CategoryType],           null: false
    field :configs,              [Types::ConfigType],             null: false
    field :problems,             [Types::ProblemType],            null: false
    field :problem_environments, [Types::ProblemEnvironmentType], null: false
    field :teams,                [Types::TeamType],               null: false
    field :notices,              [Types::NoticeType],             null: false
    field :sessions,             [Types::SessionType],            null: false
    field :scoreboards,          [Types::ScoreboardType],         null: false
    field :report_cards,         [Types::ReportCardType],         null: false

    field :penalties,            [Types::PenaltyType],            null: false do
      argument :after, Types::DateTime, required: false
    end

    field :category, Types::CategoryType, null: true do
      argument :id, ID, required: true
    end

    field :problem, Types::ProblemType, null: true do
      argument :id, ID, required: true
    end

    field :problem_environment, Types::ProblemEnvironmentType, null: true do
      argument :id, ID, required: true
    end

    field :team, Types::TeamType, null: true do
      argument :id, ID, required: true
    end

    def me
      self.current_team!.readable(team: self.current_team!)
    end

    def contest_info
      # ContestInfoTypeがrecord_accessor経由でレコード取得する
      Config
    end

    def attachments
      Attachment.readables(team: self.current_team!)
    end

    def configs
      Config.readables(team: self.current_team!)
    end

    def categories
      Category.readables(team: self.current_team!)
    end

    def category(id:)
      Category.readables(team: self.current_team!).find_by(id: id)
    end

    def penalties(after: nil)
      rel = Penalty
        .readables(team: self.current_team!)
        .order(:created_at)

      after.nil? ? rel : rel.where(created_at: after..)
    end

    def problem(id:)
      Problem.readables(team: self.current_team!).find_by(id: id)
    end

    def problems
      Problem.readables(team: self.current_team!)
    end

    def problem_environment(id:)
      ProblemEnvironment.readables(team: self.current_team!).find_by(id: id)
    end

    def problem_environments
      ProblemEnvironment.readables(team: self.current_team!)
    end

    def team(id:)
      Team.readables(team: self.current_team!).find_by(id: id)
    end

    def teams
      Team.readables(team: self.current_team!)
    end

    def notices
      Notice.readables(team: self.current_team!)
    end

    def sessions
      return [] unless self.current_team!.staff?

      Session.all
    end

    def scoreboards
      Scoreboard.readables(team: self.current_team!)
    end

    def report_cards
      ReportCard.readables(team: self.current_team!)
    end

    class << self
      def get_fields_query(name, with: nil)
        type = self.fields.fetch(name).type
        self.get_type_class(type).to_fields_query(with: with)
      end
    end
  end
end
