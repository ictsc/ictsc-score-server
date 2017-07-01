FactoryGirl.define do
  factory :attachment do
    sequence(:filename) { |n| "file_#{n}.png" }
    member
  end
end
