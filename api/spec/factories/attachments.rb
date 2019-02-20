FactoryBot.define do
  factory :attachment do
    sequence(:filename) {|n| "file_#{n}.png" }
    access_token { 'dummy_access_token' }
    data { 'dummy_data' }
    member
  end
end
