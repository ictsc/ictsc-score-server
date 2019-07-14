# frozen_string_literal: true

FactoryBot.define do
  factory :issue do
    status { Issue.statuses.keys.sample }
    problem { nil }
    team { nil }
    comments { [] }

    transient do
      comment_count { 1 }
    end

    trait :unsolved do
      status { 'unsolved' }
    end

    trait :in_progress do
      status { 'in_progress' }
    end

    trait :solved do
      status { 'solved' }
    end

    callback(:after_build, :after_stub) do |issue, evaluator|
      if issue.comments.empty? && evaluator.comment_count >= 1
        comments = build_list(:issue_comment, evaluator.comment_count)
        # コメントに時系列を付ける
        comments.each_with_index {|comment, i| comment.created_at = Time.current + i }
        # 最初のコメントは必ずplayer
        comments.first.from_staff = false
        issue.comments = comments
      end
    end
  end
end
