require_relative "../features_helper"

feature "Delete Question" do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:tags) { create_list(:tag, 5) }
  given(:question1) { create(:question, user: user1) }
  given(:question2) { create(:question, user: user2) }

  background do
    sign_in user1
  end

  scenario "User deletes his questions" do
    visit question_path(question1)

    within(".question") do
      click_on "delete-question"
    end

    expect(page).to have_selector ".alert-success", text: "deleted"
    expect(page).not_to have_content question1.body
  end
  
  scenario "User can't delete not his question" do
    visit question_path(question2)

    within(".question") do
      expect(page).not_to have_selector "#delete-question"
    end
  end
end
