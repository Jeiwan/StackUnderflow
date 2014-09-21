# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    body "This is a comment, yo!"
    commentable_id 1
    commentable_type "Question"
    user
  end
end
