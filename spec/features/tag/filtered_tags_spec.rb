require_relative "../features_helper"

feature "Fitlered Tags" do

  given(:tags) { create_list(:tag, 3) }
  given!(:question1) { create(:question, tag_list: tags[0].name) }
  given!(:question2) { create(:question, tag_list: tags[1].name) }
  given!(:question3) { create(:question, tag_list: tags[1].name) }
  given!(:question4) { create(:question, tag_list: tags[2].name) }

  scenario "User can view tags by popularity" do
    visit tags_path
    expect(page).to have_content "popular"

    expect(page).to have_selector "a[href$=#{tags[1].name}] + a[href$=#{tags[2].name}] + a[href$=#{tags[0].name}]"
  end

  scenario "User can view tags in alphabetical order" do
    visit tags_path
    expect(page).to have_link "alphabetical"
    click_link "alphabetical"

    expect(page).to have_selector "a[href$=#{tags[0].name}] + a[href$=#{tags[1].name}] + a[href$=#{tags[2].name}]"
  end

end
