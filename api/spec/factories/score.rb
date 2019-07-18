# frozen_string_literal: true

FactoryBot.define do
  factory :score do
    point { Random.rand(0..100) }
    solved { answer.problem.body.solved_criterion <= point }
    answer { nil }
  end
end
