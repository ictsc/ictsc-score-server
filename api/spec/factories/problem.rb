# frozen_string_literal: true

FactoryBot.define do
  factory :problem do
    sequence(:code) {|n| "%<name>s #{n}" } # type: :string, null: false
    sequence(:writer) {|n| "%<name>s #{n}" } # type: :string, null: true
    sequence(:secret_text) {|n| "%<name>s #{n}" } # type: :string, null: false, default: ""
    sequence(:order) {|n| n } # type: :integer, null: false
    sequence(:team_isolate, &:odd?) # type: :boolean, null: false, default: "false"
    open_at { nil } # type: :tsrange, null: true

    # association :body, factory: :problem_body # optional: nil
    # association :environments, :problem_environment # optional: nil
    # association :supplements, factory: :problem_supplement # optional: nil
    # association :category # optional: true

    # association :previous_problem, factory: :problem # optional: true
    # association :answers # optional: nil
    # association :issues # optional: nil
    # association :first_correct_answers # optional: nil
  end
end
