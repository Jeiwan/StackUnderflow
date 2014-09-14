# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :answer do
		body "This is very good indeed."
		question
		user
  end
  factory :invalid_answer, class: "Answer" do
		body ""
		question
		user
  end
end
