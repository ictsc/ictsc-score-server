require 'sinatra/crypt_helpers'

FactoryBot.define do
  factory :member do
    sequence(:name) { |n| "member_#{n}" }
    sequence(:login) { |n| "member_login_#{n}" }
    password { 'test' } # to tell plain password to spec
    hashed_password { Sinatra::CryptHelpers.hash_password(password) }
    role

    trait :admin do
      password { 'admin' }
      association :role, factory: [:role, :admin]
    end

    trait :writer do
      association :role, factory: [:role, :writer]
    end

    trait :participant do
      association :role, factory: [:role, :participant]
      team
    end

    trait :viewer do
      association :role, factory: [:role, :viewer]
    end
  end
end
