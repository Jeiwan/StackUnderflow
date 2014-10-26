require_relative "../features_helper"

feature "Filtered Questions" do
  given(:user) { create(:user) }
  given(:user2) { create(:user) }
  given!(:questions) { create_list(:question, 3, tag_list: "filtering", user: user2) }
  given(:answer) { build(:answer, question: questions[1]) }
  given(:answer_comment) { build(:answer_comment, commentable: answer) }
  given(:question_comment) { build(:question_comment, commentable: questions[0]) }

  background do
    sign_in user
    #questions[0].vote_up(user)
  end

  scenario "User visits index page and sees questions with newest on top" do
    visit root_path
    expect(page).to have_selector "#question_#{questions[2].id} + #question_#{questions[1].id} + #question_#{questions[0].id}"
  end

  scenario "User visits page with questions sorted by votes and sees questions with descending sorting" do
    questions[0].vote_up(user)
    visit root_path
    within(".questions-sorting") do
      click_link "popular"
    end

    expect(page).to have_selector "#question_#{questions[0].id} + #question_#{questions[2].id} + #question_#{questions[1].id}"
  end

  scenario "User can view a list of unanswered questions" do
    answer.save
    visit root_path
    within(".questions-sorting") do
      click_link "unanswered"
    end

    expect(page).to have_selector "#question_#{questions[2].id} + #question_#{questions[0].id}"
  end

  scenario "User can view a list of questions sorted by recent activity" do
    visit_active
    expect(page).to have_selector "#question_#{questions[2].id} + #question_#{questions[1].id} + #question_#{questions[0].id}"

    answer.save
    visit_active
    expect(page).to have_selector "#question_#{questions[1].id} + #question_#{questions[2].id} + #question_#{questions[0].id}"

    question_comment.save
    visit_active
    expect(page).to have_selector "#question_#{questions[0].id} + #question_#{questions[1].id} + #question_#{questions[2].id}"

    answer_comment.save
    visit_active
    expect(page).to have_selector "#question_#{questions[1].id} + #question_#{questions[0].id} + #question_#{questions[2].id}"

    question_comment.update(body: "When I thought that fought this war alone")
    visit_active
    expect(page).to have_selector "#question_#{questions[0].id} + #question_#{questions[1].id} + #question_#{questions[2].id}"

    questions[2].update(body: "You were there by my side on the frontline")
    visit_active
    expect(page).to have_selector "#question_#{questions[2].id} + #question_#{questions[0].id} + #question_#{questions[1].id}"

    answer_comment.update(body: "And we fought to believe the impossible")
    visit_active
    expect(page).to have_selector "#question_#{questions[1].id} + #question_#{questions[2].id} + #question_#{questions[0].id}"

  end
end

def visit_active
  visit root_path
  within(".questions-sorting") do
    click_link "active"
  end
end
