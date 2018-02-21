def hash_password(key, salt = "")
  return nil unless key.is_a? String

  crypt_binname = case RUBY_PLATFORM
    when /darwin/;  "crypt_darwin_amd64"
    when /freebsd/; "crypt_freebsd_amd64"
    when /linux/;   "crypt_linux_amd64"
  end
  path = File.expand_path("../../../ext/#{crypt_binname}", __FILE__)
  hash, status = Open3.capture2(path, key, salt)
  if status.exitstatus.zero?
    hash.strip
  else
    nil
  end
end

FactoryBot.define do
  factory :member do
    sequence(:name) { |n| "member_#{n}" }
    sequence(:login) { |n| "member_login_#{n}" }
    password 'test' # to tell plain password to spec
    hashed_password { hash_password(password) }
    role

    trait :admin do
      password 'admin'
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
