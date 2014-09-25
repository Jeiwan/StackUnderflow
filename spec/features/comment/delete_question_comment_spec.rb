require "rails_helper"

feature "Delete Question Comment" do

  given(:user) { create(:user) }
  given(:user2) { create(:user) }
  given!(:question) { create(:question, user: user) }
  given!(:comment) { create(:question_comment, user: user, commentable: question) }
  given!(:comment2) { create(:question_comment, user: user2, commentable: question) }

  background do
    sign_in user
    visit question_path(question)
  end

  scenario "User deletes his question comment", js: true do
    within(".question .comment[data-comment-id='#{comment.id}']") do
      click_on "delete"
    end
    page.driver.browser.switch_to.alert.accept

    expect(page).not_to have_selector ".content[data-comment-id='#{comment.id}']"
  end

  scenario "User can't delete not his question comment", js: true do
    within(".question .comment[data-comment-id='#{comment2.id}']") do
      expect(page).not_to have_content "delete"
    end
  end

end
