FactoryGirl.define do
  factory :answer_comment, class: 'Comment' do
    member
    association :commentable, factory: :answer

    sequence(:text) { |n| "answer_comment_#{n}" }
  end

  factory :issue_comment, class: 'Comment' do
    member
    association :commentable, factory: :issue

    sequence(:text) { |n| "issue_comment_#{n}" }
  end

  factory :problem_comment, class: 'Comment' do
    member
    association :commentable, factory: :problem

    sequence(:text) { |n| "problem_comment_#{n}" }
  end
end
