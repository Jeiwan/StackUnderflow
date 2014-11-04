# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reputation do
    value 0
    user
  end
end
