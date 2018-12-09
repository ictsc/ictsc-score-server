FactoryBot.define do
  factory :score do
    point { 42 }
    answer
    solved { false }
    association :marker, factory: [:member, :writer]
  end
end
