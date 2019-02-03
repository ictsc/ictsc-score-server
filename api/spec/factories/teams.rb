require 'sinatra/crypt_helpers'

FactoryBot.define do
  factory :team do
    sequence(:name) {|n| "team_#{n}" }
    registration_code { "#{name}_registration_code" }
  end
end
