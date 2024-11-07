FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    remaining_budget { 1000.0 }
    maximum_budget { 1000.0 }
  end
end
