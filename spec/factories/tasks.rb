FactoryGirl.define do
  factory :task do
    name { Faker::Lorem.sentence }
    is_done false
    todo_id { Faker::Number.number(10) }
  end
end
