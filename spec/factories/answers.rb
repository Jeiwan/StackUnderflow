# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :answer do
		body "Very useful answer"
		best false
		question
		user
  end
  factory :invalid_answer, class: "Answer" do
		body ""
		best false
		question
		user
  end
end
