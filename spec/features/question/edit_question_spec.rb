require_relative "../features_helper"

feature "Edit Question" do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question1) { create(:question, user: user1) }
  given(:question2) { create(:question, user: user2) }

  background do
    sign_in user1
  end

  scenario "User edits his question" do
    visit question_path(question1)

    click_link "edit-question"

    expect(page).to have_content "Body"

    fill_in "Body", with: question1.body.reverse
    click_on "Update Question"

    expect(page).to have_content question1.body.reverse
  end

  scenario "User can't edit not his question" do
    visit question_path(question2)

    expect(page).not_to have_selector "#edit-question"
  end

end
