FactoryBot.define do
  factory :problem_group do
    sequence(:name) {|n| "problem_group_#{n}" }
    sequence(:description) {|n| "problem_group_#{n}_description" }
    order { 10 }
    completing_bonus_point { 100 }
  end
end
