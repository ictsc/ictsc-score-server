FactoryBot.define do
  factory :problem do
    sequence(:title) { |n| "problem_#{n}" }
    sequence(:text) { |n| "problem_text_#{n}" }
    reference_point 21
    perfect_point 42
    order 10
    association :creator, factory: [:member, :writer]
  end
end
