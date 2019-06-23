# frozen_string_literal: true

FactoryBot.define do
  factory :problem_environment do
    sequence(:status) {|n| "status #{n}" }
    sequence(:host) {|n| "host#{n}.local" }
    sequence(:user) {|n| "user#{n}" }
    sequence(:password) {|n| "password#{n}" }
  end
end
