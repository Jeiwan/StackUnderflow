# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :answer do
		sequence(:body) { |n| "Very useful answer #{n}" }
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
