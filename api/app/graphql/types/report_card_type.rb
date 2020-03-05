# frozen_string_literal: true

module Types
  class ReportCardType < Types::BaseObject
    field :rank,              Integer,  null: true
    field :score,             Integer,  null: false
    field :team_name,         String,   null: false
    field :team_organization, String,   null: true
    field :each_score,        [Integer, null: true], null: false
    field :each_percent,      [Integer, null: true], null: false
    field :problem_titles,    [String], null: false
    field :problem_genres,    [String], null: false
  end
end
