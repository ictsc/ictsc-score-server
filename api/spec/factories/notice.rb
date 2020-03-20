# frozen_string_literal: true

FactoryBot.define do
  factory :notice do
    title { Faker::Book.title }
    text { Array.new(Random.rand(1..3)) { Faker::Books::Dune.quote }.join("\n") }
    pinned { Random.rand(4).zero? }
    team { nil }
    created_at { Time.current - Random.rand(60).minutes - Random.rand(60).seconds }
    updated_at { created_at }
  end
end
