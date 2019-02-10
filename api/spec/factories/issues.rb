FactoryBot.define do
  factory :issue do
    closed { false }
    sequence(:title) {|n| "issue_#{n}" }
    problem
    team

    trait :closed do
      closed { true }

      transient do
        comments_count { 3 }
      end

      after :create do |issue, evaluator|
        create_list(
          :issue_comment,
          evaluator.comments_count,
          member: create(:member, team: issue.team),
          commentable: issue
        )
      end
    end
  end
end
