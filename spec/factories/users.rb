FactoryBot.define do
  factory :user do
    sequence(:email) { "tester@gmail.com" }
    password { 'shohei' }
    password_confirmation { 'shohei' }
  end
end
