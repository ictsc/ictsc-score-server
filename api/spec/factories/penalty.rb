# frozen_string_literal: true

FactoryBot.define do
  factory :penalty do
    count { Random.rand(10) }
    problem { nil }
    team { nil }
  end
end
