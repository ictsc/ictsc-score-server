# frozen_string_literal: true

FactoryBot.define do
  factory :problem_supplement do
    sequence(:text) {|n| "%<name>s #{n}" } # type: :string, null: false
    # association :problem # optional: nil
  end
end
