# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    sequence(:title) { |n| "Very important question #{n}" }
    body "Answer my question ASAP!"
    tag_list "android-5.0,c#,c++,macosx,windows"
		user
  end
  factory :invalid_question, class: "Question" do
    title ""
    body ""
		user
  end
end
