# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
		sequence(:username) { |n| "Pedro#{n}" }
		sequence(:email) { |n| "pedro#{n}@mexi.co" }
		password "asdzxcasd"
		password_confirmation "asdzxcasd"
  end
end
