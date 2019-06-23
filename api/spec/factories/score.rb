# frozen_string_literal: true

FactoryBot.define do
  factory :score do
    point { Random.rand(0..100) } # type: :integer, null: false
    sequence(:solved, &:odd?) # type: :boolean, null: false, default: "false"
    association :answer # optional: nil
  end
end
