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

  scenario "User comments answer", js: true do
    post_answer_comment answer.id, comment.body

    within(".answer") do
      expect(page).to have_content comment.body
    end
  end

  scenario "User comments answer with invalid data", js: true do
    post_answer_comment answer.id, ""

    expect(page).to have_content "Invalid data!"
  end
end

def post_answer_comment answer_id, comment
    sign_in user
    visit question_path(question)

    within(".answer[data-answer-id='#{answer_id}']") do
      click_on "Comment"
      fill_in :comment_body, with: comment
      click_on "Post comment"
    end
end
