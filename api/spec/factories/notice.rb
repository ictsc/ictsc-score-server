# frozen_string_literal: true

FactoryBot.define do
  factory :notice do
    title { Faker::Book.title }
    text { Array.new(Random.rand(1..3)) { Faker::Books::Dune.quote }.join("\n") }
    pinned { Random.rand(2).odd? }
    target_team { nil }
  end
end
