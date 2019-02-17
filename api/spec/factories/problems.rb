FactoryBot.define do
  factory :problem do
    sequence(:title) {|n| "problem_#{n}" }
    sequence(:text) {|n| "problem_text_#{n}" }
    reference_point { 21 }
    perfect_point { 42 }
    order { 10 }
    team_private { false }
    secret_text { 'This is very secret text' }
    association :creator, factory: %i[member writer]

    trait :unopened do
      association :problem_must_solve_before, factory: :problem
    end
  end
end
