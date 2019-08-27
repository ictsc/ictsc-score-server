# frozen_string_literal: true

FactoryBot.define do
  code_begin = +'AAA'

  factory :category do
    code do
      code = -code_begin
      code_begin.next!
      code
    end
    sequence(:title) {|i| "グループ#{i}" }
    description { Faker::Books::Dune.saying }
    order { Random.rand(10..1000) }

    # has_many problems
  end
end
