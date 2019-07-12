# frozen_string_literal: true

FactoryBot.define do
  factory :score do
    point { Random.rand(0..100) }
    sequence(:solved, &:odd?)
    answer { nil }
  end
end
