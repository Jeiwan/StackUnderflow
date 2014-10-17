# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :impression do
    user_id 1
    question_id 1
    remote_ip "MyString"
    user_agent "MyString"
  end
end
