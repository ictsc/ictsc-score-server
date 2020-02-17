# frozen_string_literal: true

FactoryBot.define do
  factory :penalty do
    problem { nil }
    team { nil }

    # unique制約から逃れるため適当にずらす
    created_at { Time.current - Random.rand(60).minutes - Random.rand(60).seconds }
    updated_at { created_at }
  end
end
