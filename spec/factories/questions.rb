# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    title "MyString"
    body "An interesting question"
		user
  end
  factory :invalid_question, class: "Question" do
    title ""
    body ""
		user
  end
end
