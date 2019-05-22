# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    sequence(:name) {|n| "team #{n}" } # type: :string, null: false
    sequence(:password) {|n| "team #{n}" } # type: :string, null: false
    sequence(:organization) {|n| "team #{n}" } # type: :string, null: true
    sequence(:number) {|n| n }

    trait :staff do
      role { :staff }
    end

    trait :audience do
      role { :player }
    end

    trait :player do
      role { :player }
      color { '#996633' }
    end

    # association :answers # optional: nil
    # association :attachments # optional: nil
    # association :first_correct_answers # optional: nil
    # association :issues # optional: nil
    # association :notices # optional: nil
    # association :problem_environments # optional: nil
  end
end
