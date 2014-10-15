require_relative "../features_helper"

feature "Tag Pages" do

  given!(:question1) { create(:question, tag_list: "tag1,tag2") }
  given!(:question2) { create(:question, tag_list: "tag1") }
  given!(:question3) { create(:question, tag_list: "tag2") }

  scenario "User visits tag page" do
    visit tags_path

    click_link "tag1"
    expect(page).to have_content question1.title
    expect(page).to have_content question2.title

    visit tags_path
    click_link "tag2"
    expect(page).to have_content question1.title
    expect(page).to have_content question3.title
  end

end
