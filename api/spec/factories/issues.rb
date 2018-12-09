FactoryBot.define do
  factory :issue do
    closed { false }
    sequence(:title) { |n| "issue_#{n}" }
    problem
    team

    trait :closed do
      transient do
        comments_count { 3 }
      end

      closed { true }

      after :create do |user, evaluator|
        create_list(
          :issue_comment, evaluator.comments_count,
          member: team.members.first,
          commentable: issue
          )
      end
    end
  end
end
