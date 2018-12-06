FactoryBot.define do
  factory :answer do
    sequence(:text) { |n| "answer_text_#{n}" }
    association :problem, factory: :problem
    association :team, factory: :team
  end
end
