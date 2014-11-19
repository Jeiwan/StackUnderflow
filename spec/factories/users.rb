# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
		sequence(:username) { |n| "Pedro#{n}" }
		sequence(:email) { |n| "pedro#{n}@mexi.co" }
    sequence(:website) { |n| "pedro#{n}.mexi.co" }
    sequence(:location) { |n| "Barcelona#{n}" }
		sequence(:full_name) { |n| "Pedro Garcia #{n}" }
		password "asdzxcasd"
		password_confirmation "asdzxcasd"
    confirmed_at Time.now
    confirmation_sent_at 10.days.ago
    status 3
  end
end
