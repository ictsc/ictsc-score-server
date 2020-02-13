# frozen_string_literal: true

FactoryBot.define do
  alphabets = ('a'..'zz').to_a.freeze

  factory :team do
    name { "team #{alphabets[number - 1]}" }
    password { name }
    organization { "Org. #{name}" }
    secret_text { Random.rand(3).zero? ? Array.new(Random.rand(1..2)) { Faker::Books::Dune.quote }.join("\n") : '' }
    sequence(:number) {|n| n }
    created_at { Time.current - Random.rand(60).minutes - Random.rand(60).seconds }
    updated_at { created_at }
    # before_createだとbulk_insertが失敗するためhas_secure_token 長さ指定を無視してる
    channel { ApplicationRecord.generate_unique_secure_token }

    trait :staff do
      name { "staff #{alphabets[number - 1]}" }
      role { :staff }
      beginner { false }
    end

    trait :audience do
      name { "audience #{alphabets[number - 1]}" }
      role { :audience }
      beginner { false }
    end

    trait :player do
      name { "team #{alphabets[number - 1]}" }
      role { :player }
      beginner { Random.rand(4).zero? } # 1/4ぐらいをbeginnerにする
      color { Random.rand(2).odd? ? nil : Faker::Color.hex_color }
    end

    # association :answers # optional: nil
    # association :attachments # optional: nil
    # association :first_correct_answers # optional: nil
    # association :issues # optional: nil
    # association :notices # optional: nil
    # association :problem_environments # optional: nil
  end
end
