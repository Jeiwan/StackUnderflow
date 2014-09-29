require_relative "../features_helper"

feature "Ask Questions", %q{
  In order to resolve a problem
  As a registered and authenticated user
  I want to have an ability to ask, edit, and delete questions
} do

  given(:user) { create(:user) }
  given(:question) { build(:question) }

  background do
    sign_in user
    visit new_question_path
  end

  scenario "Authenticated user asks a question" do
    fill_in "Title", with: question.title
    fill_in "Body", with: question.body
    click_on "Create Question"

    expect(page).to have_content question.title
    expect(page).to have_content question.body
  end

  scenario "Authenticated user asks a question without filling required fields" do
    click_on "Create Question"

    expect(page).to have_content "problems"
  end
  
end
