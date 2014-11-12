require_relative "../features_helper"

feature "Edit Answer" do
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

  scenario "User edits his answer", js: true do
    within answer_block(answer2.id) do
      find("a.edit-answer").click
      fill_in "answer_body", with: answer2.body.reverse
      click_button "Update Answer"
    end

    expect(page).to have_content answer2.body.reverse
  end

  scenario "User edits his answer right after creating it", js: true do
    post_answer new_answer
    within("#answer_3") do
      find("a.edit-answer").click
      expect(page).to have_selector "textarea", text: new_answer.body
      fill_in "answer_body", with: new_answer.body.reverse
      click_button "Update Answer"
      expect(page).to have_content new_answer.body.reverse
      expect(page).not_to have_selector "textarea"
    end
  end

  scenario "User edits his answer right after editing it", js: true do
    post_answer new_answer
    within("#answer_3") do
      find("a.edit-answer").click
      expect(page).to have_selector "textarea", text: new_answer.body
      fill_in "answer_body", with: new_answer.body.reverse
      click_button "Update Answer"
      expect(page).to have_content new_answer.body.reverse
      expect(page).not_to have_selector "textarea"
    end
    within("#answer_3") do
      find("a.edit-answer").click
      expect(page).to have_selector "textarea", text: new_answer.body.reverse
      fill_in "answer_body", with: new_answer.body
      click_button "Update Answer"
      expect(page).to have_content new_answer.body
      expect(page).not_to have_selector "textarea"
    end
  end

  scenario "User can't edit not his answer", js: true do
    within answer_block(answer1.id) do
      expect(page).not_to have_selector "edit-answer"
    end
  end
end

def answer_block(answer_id)
  ".answers #answer_#{answer_id}"
end

def post_answer answer
  fill_in :answer_body, with: answer.body
  all("#answer-form input[type='file']")[0].set("#{Rails.root}/public/images/default_avatar.png")
  click_on "Answer"
end
