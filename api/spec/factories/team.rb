# frozen_string_literal: true

FactoryBot.define do
  alphabets = ('a'..'zz').to_a.freeze

  factory :team do
    name { "team #{alphabets[number - 1]}" }
    password { name }
    organization { "Org. #{name}" }
    sequence(:number) {|n| n }
    created_at { Time.current - Random.rand(60).minutes - Random.rand(60).seconds }
    updated_at { created_at }

    trait :staff do
      name { "staff #{alphabets[number - 1]}" }
      role { :staff }
    end

    trait :audience do
      name { "audience #{alphabets[number - 1]}" }
      role { :audience }
    end

    trait :player do
      name { "team #{alphabets[number - 1]}" }
      role { :player }
      color { Faker::Color.hex_color }
    end

    # association :answers # optional: nil
    # association :attachments # optional: nil
    # association :first_correct_answers # optional: nil
    # association :issues # optional: nil
    # association :notices # optional: nil
    # association :problem_environments # optional: nil
  end
end
