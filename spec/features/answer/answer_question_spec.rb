require_relative "../features_helper"

feature "Answer a Question", %q{
  In order to help other people
  As an authenticated user with a lot of spare time
  I want to have an ability to answer other users' questions
} do

  given(:inquirer) { create(:user) }
  given(:question) { create(:question, user: inquirer, tag_list: "test,west,best") }
  given(:answerer) { create(:user) }
  given(:answer) { build(:answer, question: question, user: answerer) }

  background do
    sign_in answerer
    visit question_path(question)
  end

  scenario "Authenticated user answers another user's question", js: true do
    fill_in :answer_body, with: answer.body
    attach_file "File", "#{Rails.root}/README.md"
    click_on "Answer"
    
    expect(current_path).to match /\/question\/\d+/
    expect(page).to have_content answer.body
    expect(page).to have_content answer.user.username
    expect(page).to have_content "README.md"
  end

  scenario "Authenticated user answers another user's question without filling a required field", js: true do
    click_on "Answer"

    expect(page).to have_selector ".alert-danger", text: "problems"
  end

end
