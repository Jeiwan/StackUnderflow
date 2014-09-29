require_relative "../features_helper"

feature "Select Best Answer" do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question1) { create(:question, user: user1) }
  given(:question2) { create(:question, user: user2) }
  given!(:answer1) { create(:answer, question: question2, user: user1) } 
  given!(:answer2) { create(:answer, question: question2, user: user1) } 
  given!(:answer3) { create(:answer, question: question1, user: user2) } 

  background do
    sign_in user2
  end

  scenario "User selects a best answer of his question" do
    select_best_answer question2

    expect(page).to have_selector ".best-answer"
  end

  scenario "User can't select a best answer of another user's question" do
    visit question_path(question1)

    expect(page).not_to have_selector ".mark-best-answer"
  end

  scenario "User can select only one best answer" do
    select_best_answer question2

    expect(page).not_to have_selector ".mark-best-answer"
  end
end

def select_best_answer(question)
  visit question_path(question)
  first(".answer").find(".mark-best-answer").click
end
