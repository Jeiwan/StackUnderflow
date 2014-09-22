require 'rails_helper'

feature "Edit Question Comment" do

  given(:user) { create(:user) }
  given(:user2) { create(:user) }
  given(:question) { create(:question, user: user) }
  given!(:answer) { create(:answer, question: question, user: user) }
  given!(:comment) { create(:answer_comment, user: user, commentable: answer) }
  given!(:comment2) { create(:answer_comment, user: user2, commentable: answer) }

  background do
    sign_in user
    visit question_path(question)
  end

  scenario "User edits his answer comment" do
    edit_answer_comment answer.id, comment.id, comment.body.reverse

    within(".answer[data-answer-id='#{answer.id}'] .comments") do
      expect(page).to have_content comment.body.reverse
    end
  end

  scenario "User edits his answer comment with valid data" do
    edit_answer_comment answer.id, comment.id, ""

    expect(page).to have_content "error"
  end

  scenario "User can't edit not his comment" do
    within(".answer[data-answer-id='#{answer.id}'] .comment[data-comment-id='#{comment2.id}']") do
      expect(page).not_to have_selector "edit"
    end
  end
end

def edit_answer_comment answer_id, comment_id, text
  within(".answer[data-answer-id='#{answer_id}'] .comment[data-comment-id='#{comment_id}']") do
    click_link "edit"
  end

  expect(page).to have_content "Edit comment"

  fill_in "comment_body", with: text
  click_on "Edit"
end
