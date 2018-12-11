FactoryBot.define do
  factory :issue_comment, class: 'Comment' do
    member
    association :commentable, factory: :issue

    sequence(:text) {|n| "issue_comment_#{n}" }
  end

  factory :problem_comment, class: 'Comment' do
    member
    association :commentable, factory: :problem

    sequence(:text) {|n| "problem_comment_#{n}" }
  end
end
