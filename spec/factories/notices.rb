FactoryGirl.define do
  factory :notice do
    sequence(:title) { |n| "notice_#{n}" }
    sequence(:text) { |n| "notice_text_#{n}" }
    pinned false

    association :member, factory: [:member, :writer]
  end
end
