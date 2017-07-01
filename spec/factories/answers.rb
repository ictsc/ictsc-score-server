FactoryGirl.define do
  factory :answer do
    completed false
    problem
    team

    trait :completed do
      transient do
        comments_count 3
      end

      completed true
      completed_at { 3.minutes.ago }

      after :create do |answer, evaluator|
        create_list(
          :answer_comment, evaluator.comments_count,
          member: team.members.first,
          commentable: answer
          )
      end
    end
  end
end
