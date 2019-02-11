FactoryBot.define do
  factory :config do
    sequence(:id) {|n| n + 100 } # 事前に作成される分があるため適当に増加
    key {|n| "key_#{id}" }
    value {|n| "value_#{id}" }
    value_type { :string }

    trait :boolean do
      value_type { :boolean }
      sequence(:value, &:odd?)
    end

    trait :integer do
      value_type { :integer }
      sequence(:value) {|n| n }
    end

    trait :string do
      value_type { :string }
      sequence(:value) {|n| "value_#{n}" }
    end

    trait :date do
      value_type { :date }
      value { DateTime.now }
    end
  end
end
