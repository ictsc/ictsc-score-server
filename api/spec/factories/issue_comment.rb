# frozen_string_literal: true

FactoryBot.define do
  factory :issue_comment do
    text { Array.new(Random.rand(1..5)) { Faker::Books::Dune.quote }.join("\n") }
    from_staff { Random.rand(2).odd? }
    issue { nil }
    created_at { Time.current - Random.rand(60).minutes - Random.rand(60).seconds }
    updated_at { created_at }
  end
end
