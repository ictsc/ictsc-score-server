# frozen_string_literal: true

FactoryBot.define do
  factory :issue_comment do
    text { Array.new(Random.rand(1..5)) { Faker::Books::Dune.quote }.join("\n") }
    from_staff { Random.rand(2).odd? }
    issue { nil }
  end
end
