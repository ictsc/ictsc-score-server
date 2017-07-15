FactoryGirl.define do
  factory :problem_group do
    sequence(:name) { |n| "problem_group_#{n}" }
    sequence(:description) { |n| "problem_group_#{n}_description" }
  end
end
