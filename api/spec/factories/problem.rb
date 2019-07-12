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

    transient do
      mode { :textbox }
    end

    callback(:after_build, :after_stub) do |problem, evaluator|
      # callbackで作らないとcreateが失敗する
      problem.body ||= build(:problem_body, evaluator.mode.to_sym)
    end

    # association :environments, :problem_environment # optional: nil
    # association :supplements, factory: :problem_supplement # optional: nil
    # association :category # optional: true

    # association :previous_problem, factory: :problem # optional: true
    # association :answers # optional: nil
    # association :issues # optional: nil
    # association :first_correct_answers # optional: nil
  end
end
