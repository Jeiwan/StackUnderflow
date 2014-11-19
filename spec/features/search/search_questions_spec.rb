require_relative "../features_helper"

feature "Search Questions" do
  given(:user) { create(:user)  }
  given!(:questions) { create_list(:question, 2)  }
  given!(:question) { create(:question, title: "This is a question to test searching functionality")  }

  given(:pedro) { create(:user, username: "pedro") }
  given(:juan) { create(:user, username: "juan") }
  given(:alejandro) { create(:user, username: "alejandro") }
  given!(:question_juan) { create(:question, user: juan, title: "2This is an question to test sortings.") }
  given!(:question_pedro) { create(:question, user: pedro, title: "1This is an question to test sortings.") }
  given!(:question_alejandro) { create(:question, user: alejandro, title: "3This is an question to test sortings.") }

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

  background do
    question_pedro.vote_up(user)
    question_pedro.vote_up(juan)
    question_juan.vote_up(pedro)
  end

  scenario "Users sorts results of a search", js: true do
    fill_in "search_query", with: "sortings"
    select "in questions", from: "search_target"
    click_button "Search"

    within(".questions-sorting") do
      expect(page).to have_link "relevance"
      expect(page).to have_link "title"
      expect(page).to have_link "date"
      expect(page).to have_link "popularity"
      expect(page).to have_link "last activity"
      expect(page).to have_link "author name"
      
      click_link "author name"
    end
    expect(page).to have_selector "#question_#{question_alejandro.id} + #question_#{question_juan.id} + #question_#{question_pedro.id}"

    within(".questions-sorting") do
      click_link "title"
    end
    expect(page).to have_selector "#question_#{question_pedro.id} + #question_#{question_juan.id} + #question_#{question_alejandro.id}"

    within(".questions-sorting") do
      click_link "date"
    end
    expect(page).to have_selector "#question_#{question_alejandro.id} + #question_#{question_pedro.id} + #question_#{question_juan.id}"

    within(".questions-sorting") do
      click_link "popularity"
    end
    expect(page).to have_selector "#question_#{question_pedro.id} + #question_#{question_juan.id} + #question_#{question_alejandro.id}"

    question_pedro.update(updated_at: Time.zone.now - 10.seconds)
    question_alejandro.update(updated_at: Time.zone.now - 5.seconds)
    question_juan.update(updated_at: Time.zone.now)
    within(".questions-sorting") do
      click_link "last activity"
    end
    expect(page).to have_selector "#question_#{question_juan.id} + #question_#{question_alejandro.id} + #question_#{question_pedro.id}"
  end
end
