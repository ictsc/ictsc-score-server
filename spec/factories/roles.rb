FactoryBot.define do
  factory :role do
    sequence(:id) { |n| n }
    sequence(:name) { |n| "role_#{n}" }
    rank 50
    initialize_with { Role.find_or_create_by(id: id)}

    trait :nologin do
      id 1
      name 'Nologin'
      rank 99
    end

    trait :admin do
      id 2
      name 'Admin'
      rank 1
    end

    trait :writer do
      id 3
      name 'Writer'
      rank 10
    end

    trait :participant do
      id 4
      name 'Participant'
      rank 20
    end

    trait :viewer do
      id 5
      name 'Viewer'
      rank 20
    end
  end
end
