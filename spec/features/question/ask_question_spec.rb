require_relative "../features_helper"

feature "Ask Questions", %q{
  In order to resolve a problem
  As a registered and authenticated user
  I want to have an ability to ask, edit, and delete questions
} do

  given(:user) { create(:user) }
  given(:tags) { build_list(:tag, 5) }
  given(:question) { build(:question, tags: tags) }

  background do
    sign_in user
    visit new_question_path
  end

  scenario "Authenticated user asks a question" do
    fill_in "Title", with: question.title
    fill_in "Body", with: question.body
    fill_in "Tags", with: tags.map(&:name).join(",")
    click_on "Create Question"

    expect(current_path).to match /\/questions\/\d+\z/

    expect(page).to have_content question.title
    expect(page).to have_content question.body
    tags.each do |tag|
      expect(page).to have_content tag.name
    end
  end

  scenario "Authenticated user asks a question without filling required fields" do
    click_on "Create Question"

    expect(current_path).to match /\/questions\z/

    expect(page).to have_content "problems"
  end

  scenario "User creates a question without specifying a tag" do
    fill_in "Title", with: question.title
    fill_in "Body", with: question.body
    fill_in "Tags", with: ""
    click_on "Create Question"

    expect(current_path).to match /\/questions\z/
    expect(page).to have_content "problems"
  end
end
