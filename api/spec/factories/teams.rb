FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "team_#{n}" }
    registration_code { "#{name}_registration_code" }
    hashed_registration_code { Crypt.hash_password(registration_code) }
  end
end
