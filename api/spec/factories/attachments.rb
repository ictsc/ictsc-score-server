FactoryBot.define do
  factory :attachment do
    sequence(:filename) { |n| "file_#{n}.png" }
    access_token { 'dummy access token' }
    data { 'dummy data' }
    member
  end
end
