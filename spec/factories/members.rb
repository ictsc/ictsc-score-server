FactoryGirl.define do
  factory :member do
    sequence(:name) { |n| "member_#{n}" }
    sequence(:login) { |n| "member_login_#{n}" }
    password 'test' # to tell plain password to spec
    hashed_password '$6$yTs.6.WlLAqHM$.r9svSkmd6beXtk9jkn8FZNdWhsxikXob2bTM/oiSubAl6EPG8occUzebA2hF2MHI1lXbNQMBPAyjcSbCeZZM0'
    role

    trait :admin do
      association :role, factory: [:role, :admin]
    end

    trait :writer do
      association :role, factory: [:role, :writer]
    end

    trait :participant do
      association :role, factory: [:role, :participant]
      team
    end

    trait :viewer do
      association :role, factory: [:role, :viewer]
    end
  end
end
