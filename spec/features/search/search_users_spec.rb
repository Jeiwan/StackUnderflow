require_relative "../features_helper"

feature "Search Users" do
  given!(:user) { create(:user)  }
  given!(:users) { create_list(:user, 10)  }
  given!(:user_with_name) { create(:user, username: "findme") }
  given!(:user_with_location) { create(:user, location: "findme") }
  given!(:user_with_website) { create(:user, website: "findme") }
  given!(:user_with_full_name) { create(:user, full_name: "findme") }

  background do
    sign_in user
    visit root_path
  end

  scenario "User searches in users", js: true do
    expect(page).to have_selector "form#search"
    expect(page).to have_selector "input#search_query"
    expect(page).to have_selector "select#search_target"
    expect(page).to have_selector "input[value='Search']"

    fill_in "search_query", with: "findme"
    select "in users", from: "search_target"
    click_button "Search"

    expect(page).to have_content "4 users found"
    expect(page).to have_selector ".user", count: 4
    expect(page).to have_selector ".username", text: user_with_name.username
    expect(page).to have_selector ".location", text: user_with_name.location
    expect(page).to have_selector ".website", text: user_with_name.website
    expect(page).to have_selector ".full_name", text: user_with_name.full_name
  end
end
