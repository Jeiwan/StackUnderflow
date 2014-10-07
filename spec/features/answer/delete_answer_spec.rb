require_relative "../features_helper"

feature "Delete Answer" do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question) { create(:question, user: user1) }
  given!(:answer1) { create(:answer, user: user1, question: question) }
  given!(:answer2) { create(:answer, user: user2, question: question) }
  given(:new_answer) { build(:answer, user: user2, question: question) }

  background do
    sign_in user2
    visit question_path(question)
  end

  scenario "User deletes his answer", js: true do

    within answer_block(answer2.id) do
      click_link "delete-answer"
    end

    expect(page).not_to have_selector answer_block(answer2.id)
    expect(page).not_to have_content answer2.body
  end

  scenario "User deletes his answer right after creating it", js: true do
    post_answer new_answer

    within answer_block(3) do
      click_link "delete-answer"
    end

    expect(page).not_to have_selector answer_block(new_answer.id)
    expect(page).not_to have_content new_answer.body
  end

  scenario "User can't delete not his answer", js: true do
    within answer_block(answer1.id) do
      expect(page).not_to have_selector "#delete-answer"
    end
  end
end

def answer_block(answer_id)
  ".answers #answer_#{answer_id}"
end

def post_answer answer
  fill_in :answer_body, with: answer.body
  attach_file "File", "#{Rails.root}/README.md"
  click_on "Answer"
end
