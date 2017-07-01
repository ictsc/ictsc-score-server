FactoryGirl.define do
  factory :problem_group do
    sequence(:name) { |n| "problem_group_#{n}" }
  end
end
