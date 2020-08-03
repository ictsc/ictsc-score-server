# frozen_string_literal: true

FactoryBot.define do
  factory :answer do
    created_at { Time.current }
    updated_at { created_at }
    confirming { Random.rand(2).odd? }

    bodies do
      case problem.body.mode
      when 'textbox'
        [[Faker::Books::Dune.quote]]
      when 'radio_button'
        problem.body.candidates.map {|c| [c.sample] }
      when 'checkbox'
        problem.body.candidates.map {|c| c.sample(Random.rand(1..c.size)) }
      else
        raise UnhandledProblemBodyMode, problem.body.mode
      end
    end

    problem { nil }
    team { nil }
    # association :first_correct_answer # optional: nil

    trait :created_at_after_delay do
      created_at { Time.current - Config.grading_delay_sec }
    end

    trait :created_at_random do
      # unique制約から逃れるため適当にずらす
      created_at { Time.current - Random.rand(60).minutes - Random.rand(60).seconds }
    end
  end
end
