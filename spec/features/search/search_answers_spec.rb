require_relative "../features_helper"

feature "Search Answers" do
  given(:user) { create(:user)  }
  given!(:questions) { create_list(:question, 2)  }
  given!(:answer1) { create(:answer, question: questions[0]) }
  given!(:answer2) { create(:answer, question: questions[1]) }
  given!(:question) { create(:question, title: "This is a question to test searching functionality")  }
  given!(:answer) { create(:answer, body: "This is an answer to test searching functionality")  }

  background do
    sign_in user
    visit root_path
  end

  scenario "User searches in answers", js: true do
    expect(page).to have_selector "form#search"
    expect(page).to have_selector "input#search_query"
    expect(page).to have_selector "select#search_target"
    expect(page).to have_selector "input[value='Search']"

    fill_in "search_query", with: "searching"
    select "in answers", from: "search_target"
    click_button "Search"

    expect(page).to have_content "1 answer found"
    expect(page).to have_selector ".answer", count: 1
    expect(page).to have_content answer.body
  end

  scenario "User searches in answers with blank query", js: true do
    fill_in "search_query", with: ""
    select "in answers", from: "search_target"
    click_button "Search"

    expect(page).to have_content "0 answers found"
    expect(page).not_to have_selector ".answer"
  end
end
