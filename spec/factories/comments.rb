# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question_comment, class: "Comment" do
    body "This is a question comment, yo!"
    association :commentable, factory: :question
    user
  end
  factory :answer_comment, class: "Comment" do
    body "This is an answer comment, yo!"
    association :commentable, factory: :answer
    user
  end
end
