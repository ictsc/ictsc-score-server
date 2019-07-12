# frozen_string_literal: true

FactoryBot.define do
  gen_cand = proc { Array.new(Random.rand(2..7)) { Faker::Coffee.blend_name }.uniq }

  factory :problem_body do
    mode { 'textbox' }
    title { Faker::Book.title }
    text { Array.new(Random.rand(4..10)) { Faker::Books::Dune.quote }.join("\n") }
    perfect_point { Random.rand(10..1000) }
    problem { nil }

    transient do
      candidates_count { Random.rand(1..5) }
    end

    trait :textbox do
      mode { 'textbox' }
    end

    trait :radio_button do
      mode { 'radio_button' }
      candidates { Array.new(candidates_count) { gen_cand.call } }
      corrects { candidates.map {|c| c.sample(1) } }
    end

    trait :checkbox do
      mode { 'checkbox' }
      candidates { Array.new(candidates_count) { gen_cand.call } }
      corrects { candidates.map {|c| c.sample(Random.rand(1..c.size)) } }
    end
  end
end
