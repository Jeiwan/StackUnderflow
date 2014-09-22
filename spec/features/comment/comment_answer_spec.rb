require 'rails_helper'

feature "Answer Commenting", %q{
  In order to clarify something
  As an authenticated user
  I want to comment answers
} do

  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given(:answer) { create(:answer, user: user, question: question) }
  given(:comment) { build(:answer_comment, user: user, commentable: answer) }

  scenario "User comments answer" do
    post_comment comment.body

    within(".answer") do
      expect(page).to have_content comment.body
    end
  end

  scenario "User comments answer with invalid data" do
    post_comment ""

    expect(page).to have_content "Ivalid data!"
  end
end

def post_comment comment
    sign_in user
    visit question_path(question)

    within(".answer") do
      click_on "Comment"
    end

    fill_in :comment_body, with: comment
    within(".answer") do
      click_on "Post comment"
    end
end
