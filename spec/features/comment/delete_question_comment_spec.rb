require "rails_helper"

feature "Delete Question Comment" do

  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given(:comment) { create(:question_comment, user: user, commentable: question) }

  background do
    sign_in user
    visit question_path(question)
  end

  scenario "User deletes his question comment" do
    within(".comment[data-comment-id='#{comment.id}']") do
      click_on "delete"
    end

    within(".comments") do
      expect(page).not_to have_content comment.body
    end
  end

end
