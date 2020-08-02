# frozen_string_literal: true

FactoryBot.define do
  factory :score do
    # factoryではなくAnswer#gradeで作成すべき
    percent { nil }
    point { nil }
    solved { nil }
    answer { nil }
  end
end
