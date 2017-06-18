FactoryGirl.define do
  factory :public_todo do
    title { Faker::Lorem.word }
    user_id { Faker::Number.number(10) }
    type { 'PublicTodo' }
  end
end
