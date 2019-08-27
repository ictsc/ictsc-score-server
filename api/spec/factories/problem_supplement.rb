# frozen_string_literal: true

FactoryBot.define do
  factory :problem_supplement do
    text { Array.new(Random.rand(1..2)) { Faker::Books::Dune.quote }.join("\n") }
    problem { nil }
  end
end
