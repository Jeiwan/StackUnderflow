# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :impression do
    sequence(:remote_ip) { |n| "127.0.0.#{n}" }
    sequence(:user_agent) { |n| "IE#{n}" }
    question
  end
end
