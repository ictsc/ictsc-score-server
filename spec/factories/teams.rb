FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "team_#{n}" }
    sequence(:registration_code) { |n| "team_#{n}_registration_code" }
  end
end
