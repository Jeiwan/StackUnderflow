require "rails_helper"

feature "Delete Question Comment" do

  given(:user) { create(:user) }
  given(:user2) { create(:user) }
  given(:question) { create(:question, user: user) }
  given!(:answer) { create(:answer, user:user, question: question) }
  given!(:comment) { create(:answer_comment, user: user, commentable: answer) }
  given!(:comment2) { create(:answer_comment, user: user2, commentable: answer) }

  background do
    sign_in user
    visit question_path(question)
  end

  scenario "User deletes his answer comment", js: true do
    within(".answer[data-answer-id='#{answer.id}'] .comment[data-comment-id='#{comment.id}']") do
      click_on "delete"
    end
    page.driver.browser.switch_to.alert.accept

    expect(page).not_to have_selector ".answers .content[data-comment-id='#{comment.id}']"
  end

  scenario "User can't delete not his answer comment", js: true do
    within(".answer[data-answer-id='#{answer.id}'] .comment[data-comment-id='#{comment2.id}']") do
      expect(page).not_to have_content "delete"
    end
  end

end
