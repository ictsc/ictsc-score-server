# frozen_string_literal: true

FactoryBot.define do
  factory :problem_supplement do
    text { Array.new(Random.rand(1..2)) { Faker::Books::Dune.quote }.join("\n") }
    problem { nil }
    created_at { Time.current - Random.rand(60).minutes - Random.rand(60).seconds }
    updated_at { created_at }
  end
end
