require_relative "../features_helper"

feature "Users Page" do
  let!(:users) { create_list(:user, 3) }

  before do
    users[0].update(username: "bbb", reputation: 5)
    users[2].update(username: "aaa", reputation: 10)
    users[1].update(username: "ccc", reputation: 15)
  end

  scenario "User can see a list of all users sorted by rating" do
    visit root_path
    click_link "Users"

    expect(page).to have_content "by reputation"

    expect(page).to have_selector "#user_#{users[1].id} + #user_#{users[2].id} + #user_#{users[0].id}"
  end

  scenario "User can see a list of all users sorted alphabetically" do
    visit root_path
    click_link "Users"

    expect(page).to have_selector "a", text: "alphabetically"
    click_link "alphabetically"

    expect(page).to have_selector "#user_#{users[2].id} + #user_#{users[0].id} + #user_#{users[1].id}"
  end

  scenario "User can see a list of all users sorted by registration date" do
    visit root_path
    click_link "Users"

    expect(page).to have_selector "a", text: "by registration"
    click_link "by registration"

    expect(page).to have_selector "#user_#{users[2].id} + #user_#{users[1].id} + #user_#{users[0].id}"
  end
end
