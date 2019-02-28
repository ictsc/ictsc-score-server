require 'digest/sha1'

FactoryBot.define do
  factory :team do
    sequence(:name) {|n| "team_#{n}" }
    organization { "organization_of_#{name}" }
    registration_code { "#{name}_registration_code" }
    hashed_registration_code { Digest::SHA1.hexdigest("#{name}_registration_code") }
  end
end
