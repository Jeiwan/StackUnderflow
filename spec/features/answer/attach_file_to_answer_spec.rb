require_relative "../features_helper"

feature "Attach File to Answer" do
  given(:user1) { create(:user) }
  given(:question) { create(:question, user: user1) }
  given(:user2) { create(:user) }
  given(:answer) { build(:answer, question: question, user: user2) }

  background do
    sign_in user2
    visit question_path(question)
  end

  scenario "User uploads a file", js: true do
    fill_in :answer_body, with: answer.body
    all("#answer-form input[type='file']")[0].set("#{Rails.root}/README.md")
    click_on "Answer"

    expect(current_path).to match /\/questions\/\d+\z/

    expect(page).to have_content answer.body
    expect(page).to have_content answer.user.username
    expect(page).to have_link "README.md"
  end

  scenario "User uploads multiple files", js: true do
    fill_in :answer_body, with: answer.body
    all("#answer-form input[type='file']")[0].set("#{Rails.root}/README.md")
    click_link "Add file"
    all("input[type='file']").last.set("#{Rails.root}/Gemfile")
    click_on "Answer"

    expect(current_path).to match /\/questions\/\d+\z/

    expect(page).to have_content answer.body
    expect(page).to have_content answer.user.username
    expect(page).to have_link "README.md"
    expect(page).to have_link "Gemfile"
  end

  scenario "User deletes attached file", js: true do
    fill_in :answer_body, with: answer.body
    all("#answer-form input[type='file']")[0].set("#{Rails.root}/README.md")
    click_on "Answer"

    within(".answer .answer-attachments") do
      click_link "Delete"
    end
    expect(page).not_to have_link "README.md"
  end

  #scenario "User uploads file after a failing validation", js: true do
    #all("#answer-form input[type='file']")[0].set("#{Rails.root}/README.md")
    #click_on "Answer"

    #expect(page).to have_content "problems"

    #fill_in :answer_body, with: answer.body
    #click_on "Answer"

    #expect(page).to have_content answer.body
    #expect(page).to have_content answer.user.username
    #expect(page).to have_link "README.md"
  #end
end
