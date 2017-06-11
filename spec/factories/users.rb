FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "foo-#{n}@bar.com"
    end
    name { Faker::Name.name }
    password 'foobar'
  end
end
