FactoryBot.define do
  require 'sinatra/crypt_helpers'

  factory :team do
    sequence(:name) { |n| "team_#{n}" }
    registration_code { "#{name}_registration_code" }
    hashed_registration_code { Sinatra::CryptHelpers.hash_password(registration_code) }
  end
end
