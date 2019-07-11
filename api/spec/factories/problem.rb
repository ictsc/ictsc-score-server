# frozen_string_literal: true

FactoryBot.define do
  code_begin = +'AAA'

  factory :problem do
    code do
      code = -code_begin
      code_begin.next!
      code
    end
    writer { Faker::Book.author }
    secret_text { Faker::Books::Dune.planet }
    order { Random.rand(1000) }
    team_isolate { false }
    open_at { nil }

    category { nil }
    association :body, factory: :problem_body
    # association :environments, :problem_environment # optional: nil
    # association :supplements, factory: :problem_supplement # optional: nil
    # association :category # optional: true

    # association :previous_problem, factory: :problem # optional: true
    # association :answers # optional: nil
    # association :issues # optional: nil
    # association :first_correct_answers # optional: nil

    trait :mode_textbox do
      association :body, :textbox, factory: :problem_body
    end

    trait :mode_radio_button do
      association :body, :radio_button, factory: :problem_body
    end

    trait :mode_checkbox do
      association :body, :checkbox, factory: :problem_body
    end

    trait :team_isolate do
      team_isolate { true }
    end
  end
end
