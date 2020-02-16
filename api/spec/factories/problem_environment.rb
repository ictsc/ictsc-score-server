# frozen_string_literal: true

FactoryBot.define do
  factory :problem_environment do
    # composite primary key
    sequence(:name) {|n| "server#{n}" }
    team { nil }
    problem { nil }

    # IN_WAITING_FOR_START IN_FILE_COPYING IN_INITIALIZE INITIALIZED IN_PLANNING PLANNED IN_APPLYING APPLIED IN_DESTROYING DESTROYED FAILED
    status { %w[APPLIED IN_DESTROYING PLANNED].sample }
    sequence(:host) {|n| "host#{n}.local" }
    sequence(:user) {|n| "user#{n}" }
    sequence(:password) {|n| "password#{n}" }
    note { Random.rand(2).odd? ? Faker::Books::Dune.quote : nil }
    created_at { Time.current - Random.rand(60).minutes - Random.rand(60).seconds }
    updated_at { created_at }
  end
end
