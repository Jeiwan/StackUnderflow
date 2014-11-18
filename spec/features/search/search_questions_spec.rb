require_relative "../features_helper"

feature "Search Questions" do
  given(:user) { create(:user)  }
  given!(:questions) { create_list(:question, 2)  }
  given!(:question) { create(:question, title: "This is a question to test searching functionality")  }

  background do
    sign_in user
    visit root_path
  end

  scenario "User searches in questions", js: true do
    expect(page).to have_selector "form#search"
    expect(page).to have_selector "input#search_query"
    expect(page).to have_selector "select#search_target"
    expect(page).to have_selector "input[value='Search']"

    fill_in "search_query", with: "searching"
    select "in questions", from: "search_target"
    click_button "Search"

    expect(page).to have_content "1 question found"
    expect(page).to have_selector ".question", count: 1
    expect(page).to have_content question.title
  end

  scenario "User searches in questions with blank query", js: true do
    fill_in "search_query", with: ""
    select "in questions", from: "search_target"
    click_button "Search"

    expect(page).to have_content "0 questions found"
    expect(page).not_to have_selector ".question"
  end
end
