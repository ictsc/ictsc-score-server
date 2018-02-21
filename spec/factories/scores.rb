FactoryBot.define do
  factory :score do
    point 42
    answer
    association :marker, factory: [:member, :writer]
  end
end
