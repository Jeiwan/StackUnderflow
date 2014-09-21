require 'rails_helper'

feature "Questions Commenting", %q{
  In order to clarify something
  As an authenticated user
  I want to comment questions
} do

  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given(:comment) { build(:comment, user: user, question: question) }

  background do
    sign_in user
    visit question_path(question)
  end

  scenario "User comments question" do
    within(".question") do
      click_on "Comment"
    end

    fill_in "comment_body", with: comment.body
    within(".question") do
      click_on "Post comment"
    end

    within(".question") do
      expect(page).to have_content comment.body
    end
  end

end
