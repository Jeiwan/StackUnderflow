require_relative "../features_helper"

feature "Filtered Questions" do
  given(:user) { create(:user) }
  given(:user2) { create(:user) }
  given!(:questions) { create_list(:question, 3, tag_list: "filtering", user: user2) }
  given(:answer) { build(:answer, question: questions[1]) }

  background do
    sign_in user
    questions[0].vote_up(user)
  end

  scenario "User visits index page and sees questions with newest on top" do
    visit root_path
    expect(page).to have_selector "#question_#{questions[2].id} + #question_#{questions[1].id} + #question_#{questions[0].id}"
  end

  scenario "User visits page with questions sorted by votes and sees questions with descending sorting" do
    visit root_path
    within(".questions-sorting") do
      click_link "votes"
    end

    expect(page).to have_selector "#question_#{questions[0].id} + #question_#{questions[2].id} + #question_#{questions[1].id}"
  end

  scenario "User can view a list of unanaswered questions" do
    answer.save
    visit root_path
    within(".questions-sorting") do
      click_link "unanswered"
    end

    expect(page).to have_selector "#question_#{questions[2].id} + #question_#{questions[0].id}"
  end

  scenario "User can view a list of questions sorted by recent activity" do
    visit root_path
    within(".questions-sorting") do
      click_link "activity"
    end
    expect(page).to have_selector "#question_#{questions[2].id} + #question_#{questions[1].id} + #question_#{questions[0].id}"
  end

end
