require_relative "../features_helper"

feature "Question has tags" do

  given!(:tags) { create_list(:tag, 5) }
  given!(:question) { create(:question, tag_list: tags.map(&:name).join(","))  }

  scenario "User visits root path and sees that questions have tags" do
    visit root_path

    tags.each do |tag|
      expect(page).to have_content tag.name
    end
  end

  scenario "User visits a question and sees that the question has tags" do
    visit question_path(question)

    tags.each do |tag|
      expect(page).to have_content tag.name
    end
  end

  scenario "User can visit tag list page from the home page" do
    visit root_path
    click_link "Tags"

    expect(current_path).to match /\/tags\z/
  end

  scenario "User visits a tag list page and sees all tags" do
    visit tags_path

    tags.each do |tag|
      expect(page).to have_content tag.name
    end
  end

end
