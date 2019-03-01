FactoryBot.define do
  factory :answer do
    sequence(:text) {|n| "answer_text_#{n}" }
    problem
    team
    # DateTIme.nowがallowで固定されているとunique制約に引っかかる
    sequence(:created_at) {|n| DateTime.current + n.second }
  end
end
