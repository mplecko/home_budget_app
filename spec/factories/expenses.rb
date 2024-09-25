FactoryBot.define do
  factory :expense do
    description { 'Grocery Shopping' }
    amount { 50.0 }
    date { Date.today }
    association :category
    association :user
  end
end
