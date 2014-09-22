# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question_comment, class: "Comment" do
    body "This is a question comment, yo!"
    association :commentable, factory: :question
    user
  end
end
