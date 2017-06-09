FactoryGirl.define do
  factory :task do
    name { Faker::Lorem.sentence }
    is_done false
    todo_id nil
  end
end
