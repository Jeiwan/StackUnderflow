require_relative "../features_helper"

feature "Attach File to Question" do
  given(:user) { create(:user) }
  given(:tags) { build_list(:tag, 5) }
  given(:question) { build(:question, tags: tags) }

  background do
    sign_in user
    visit new_question_path
  end

  scenario "User uploads a file" do
    fill_in "Title", with: question.title
    fill_in "Body", with: question.body
    fill_in "Tags", with: tags.map(&:name).join(",")
    attach_file "File", "#{Rails.root}/Gemfile"
    click_on "Create Question"

    expect(current_path).to match /\/questions\/\d+\z/

    expect(page).to have_content question.title
    expect(page).to have_content question.body
    tags.each do |tag|
      expect(page).to have_content tag.name
    end
    expect(page).to have_link "Gemfile"
  end

  scenario "User uploads multiple files", js: true do
    fill_in "Title", with: question.title
    fill_in "Body", with: question.body
    page.execute_script("$('#question_tag_list').val('#{tags.map(&:name).join(',')}')")
    #attach_file "File", "#{Rails.root}/Gemfile"
    all(".new_question input[type='file']")[0].set("#{Rails.root}/Gemfile")

    click_link "Add file"
    all("input[type='file']").last.set("#{Rails.root}/README.md")

    click_on "Create Question"

    expect(current_path).to match /\/questions\/\d+\z/

    expect(page).to have_content question.title
    expect(page).to have_content question.body
    tags.each do |tag|
      expect(page).to have_content tag.name
    end
    expect(page).to have_link "Gemfile"
    expect(page).to have_content "README.md"
  end

  scenario "User uploads file after a failing validation", js: true do
    all(".new_question input[type='file']")[0].set("#{Rails.root}/Gemfile")
    click_on "Create Question"

    expect(page).to have_content "problems"

    fill_in "Title", with: question.title
    fill_in "Body", with: question.body
    page.execute_script("$('#question_tag_list').val('#{tags.map(&:name).join(',')}')")
    click_on "Create Question"

    expect(current_path).to match /\/questions\/\d+\z/
    expect(page).to have_content question.title
    expect(page).to have_content question.body
    tags.each do |tag|
      expect(page).to have_content tag.name
    end
    expect(page).to have_link "Gemfile"
  end
end
