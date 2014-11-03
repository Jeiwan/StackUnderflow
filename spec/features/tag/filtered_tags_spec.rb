require_relative "../features_helper"

feature "Fitlered Tags" do

  given(:tags) { create_list(:tag, 3) }
  given!(:question1) { create(:question, tag_list: tags[0].name) }
  given!(:question2) { create(:question, tag_list: tags[1].name) }
  given!(:question3) { create(:question, tag_list: tags[1].name) }
  given!(:question4) { create(:question, tag_list: tags[2].name) }

  scenario "User can view tags by popularity" do
    visit tags_path
    expect(page).to have_content "alphabetical"

    expect(page).to have_selector "#tag_#{tags[0].id} + #tag_#{tags[1].id} + #tag_#{tags[2].id}"
  end

  scenario "User can view tags in alphabetical order" do
    visit tags_path
    expect(page).to have_link "popular"
    click_link "popular"

    expect(page).to have_selector "#tag_#{tags[1].id} + #tag_#{tags[2].id} + #tag_#{tags[0].id}"
  end

  scenario "User can view tags sorted by the date of creation" do
    visit tags_path
    expect(page).to have_link "newest"
    click_link "newest"

    expect(page).to have_selector "#tag_#{tags[2].id} + #tag_#{tags[1].id} + #tag_#{tags[0].id}"
  end
end
