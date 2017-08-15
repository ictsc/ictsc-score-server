FactoryGirl.define do
  factory :answer do
    sequence(:text) { |n| "answer_text_#{n}" }
    problem
    team
  end
end
