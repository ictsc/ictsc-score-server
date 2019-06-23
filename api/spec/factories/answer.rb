# frozen_string_literal: true

FactoryBot.define do
  factory :answer do
    # mode {  }
    sequence(:bodies) {|_n| '' } # type: :json, null: false
    sequence(:created_at) {|n| Time.current + n.second } # type: :datetime, null: false
    sequence(:updated_at) {|n| Time.current + n.second } # type: :datetime, null: false
    # association :problem # optional: nil
    # association :team # optional: nil
    # association :first_correct_answer # optional: nil
  end
end
